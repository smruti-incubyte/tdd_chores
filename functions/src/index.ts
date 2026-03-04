import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

/**
 * Triggered when a new document is added to `single_chores` or `group_chores`.
 * Sends a push notification to all users except the one who created the chore.
 *
 * @param {string} choreName - Display name of the chore.
 * @param {string | undefined} createdBy - UID of the chore creator.
 * @param {string} collectionLabel - Collection name used as notification data.
 */
async function notifyOthersOnChoreAdded(
  choreName: string,
  createdBy: string | undefined,
  collectionLabel: string
): Promise<void> {
  const db = admin.firestore();
  const messaging = admin.messaging();

  // Fetch all user docs
  const usersSnapshot = await db.collection("users").get();

  const tokenFetches = usersSnapshot.docs
    .filter((userDoc) => userDoc.id !== createdBy)
    .map((userDoc) =>
      db.collection("users").doc(userDoc.id).collection("tokens").get()
    );

  const tokenSnapshots = await Promise.all(tokenFetches);

  const tokens: string[] = tokenSnapshots
    .flatMap((snap) => snap.docs)
    .map((doc) => doc.data().token as string)
    .filter(Boolean);

  if (tokens.length === 0) {
    logger.info(`No tokens to notify for ${collectionLabel} chore.`);
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
  "single_chores/{choreId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    await notifyOthersOnChoreAdded(
      data.name as string,
      data.createdBy as string | undefined,
      "single_chore"
    );
  }
);

export const onGroupChoreAdded = onDocumentCreated(
  "group_chores/{choreId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    // Group chores use the dateTime as a human-readable label
    const label = (data.dateTime as string) ?? "Group chore";

    await notifyOthersOnChoreAdded(
      label,
      data.createdBy as string | undefined,
      "group_chore"
    );
  }
);
