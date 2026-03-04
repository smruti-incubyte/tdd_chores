import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

/**
 * Triggered when a new document is added to `single_chores` or `group_chores`.
 * Sends a push notification to all users.
 *
 * @param {string} choreName - Display name of the chore.
 * @param {string} collectionLabel - Collection name used as notification data.
 */
async function notifyAllOnChoreAdded(
  choreName: string,
  collectionLabel: string
): Promise<void> {
  const db = admin.firestore();
  const messaging = admin.messaging();

  // Fetch all user docs
  const usersSnapshot = await db.collection("users").get();

  logger.info(`Found ${usersSnapshot.docs.length} user(s).`);

  const tokenFetches = usersSnapshot.docs.map((userDoc) =>
    db.collection("users").doc(userDoc.id).collection("tokens").get()
  );

  const tokenSnapshots = await Promise.all(tokenFetches);

  const allTokenDocs = tokenSnapshots.flatMap((snap) => snap.docs);
  logger.info(`Found ${allTokenDocs.length} token doc(s) across all users.`);

  const tokens: string[] = allTokenDocs
    .map((doc) => {
      const token = doc.data().token as string | undefined;
      logger.info(`Token doc ${doc.id}: token=${token}`);
      return token;
    })
    .filter((t): t is string => !!t);

  if (tokens.length === 0) {
    logger.warn(`No valid tokens found for ${collectionLabel} chore.`);
    return;
  }

  logger.info(
    `Sending notifications to ${tokens.length} token(s) ` +
    `for chore "${choreName}".`
  );

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: "New chore added",
      body: choreName,
    },
    data: {
      type: collectionLabel,
    },
  });

  // Log any failed sends without throwing — stale tokens are expected
  response.responses.forEach((res, idx) => {
    if (!res.success) {
      logger.warn(`Token ${tokens[idx]} failed: ${res.error?.message}`);
    }
  });
}

export const onSingleChoreAdded = onDocumentCreated(
  {document: "single_chores/{choreId}", region: "us-central1"},
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("onSingleChoreAdded: no data associated with the event");
      return;
    }
    const data = snapshot.data();

    await notifyAllOnChoreAdded(
      data.name as string,
      "single_chore"
    );
  }
);

export const onGroupChoreAdded = onDocumentCreated(
  {document: "group_chores/{choreId}", region: "us-central1"},
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("onGroupChoreAdded: no data associated with the event");
      return;
    }
    const data = snapshot.data();

    // Group chores use the dateTime as a human-readable label
    const label = (data.dateTime as string) ?? "Group chore";

    await notifyAllOnChoreAdded(
      label,
      "group_chore"
    );
  }
);
