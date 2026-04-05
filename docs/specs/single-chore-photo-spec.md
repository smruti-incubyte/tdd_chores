# Spec: Single chore photo upload

## Overview

Users can attach an optional photo when creating a single chore. The image is stored in Firebase Storage; the Firestore `single_chores` document stores a download URL. The single-chores list shows a thumbnail when a photo exists. Deleting a chore removes its Firestore document and deletes the Storage file when present.

**Delivery:** Implement **one slice at a time**. Finish and verify slice *N* before writing slice *N+1* production code. Do not mix layers across slices (e.g. no `ChoresBloc` changes in slice 1).

**TDD:** For **every** layer — **domain**, **data**, and **presentation** — follow the same loop. Each slice lists what to test for that layer only.

**TDD process (repeat until tests pass):**

1. **Start by writing the test** — express the behavior you want (red conceptually once the suite runs).
2. **Fix compilation errors** — add or adjust production code so the project compiles: in slice 1 typically **entity**, **use case**, and **repository** (abstract contract); in slice 2 **model**, **Firebase/storage services**, **repository implementation**; in slice 3 **bloc**, **events/state**, **widgets** as needed.
3. **Run the tests.**
4. **Fix the tests** (or fix production code) until assertions match the spec.
5. **Repeat** from step 1 for the next behavior or next slice.

## Slices

### Slice 1 — Domain

Implement **only** the domain layer for this feature (no data-source implementations, no bloc/UI changes beyond what existing tests force).

- [x] `SingleChore` entity includes optional `photoUrl` (`String?`); equality / `props` include it where relevant
- [x] `ChoreRepository` contract extended so the two use cases below have clear ports (e.g. upload/delete-by-URL on the storage side, plus existing Firestore single-chore CRUD for `photoUrl`)

**Domain use cases (required)**

- [x] **`SavePhoto`** — inputs: stable chore document id + domain-approved local file reference (e.g. file path or abstraction); output: download URL string for attaching to the entity. Invokes repository/storage port; implementation in slice 2
- [x] **`DeletePhoto`** — inputs: stored photo identifier the domain agrees on (typically the **download URL** `String`, matching `refFromURL` usage in slice 2); removes the file in remote storage only (Firestore document updates remain with `deleteSingleChore` / other use cases). Invokes repository/storage port; implementation in slice 2

**TDD (domain)**

- [x] Unit tests for **`SavePhoto`** and **`DeletePhoto`** using **mocked** `ChoreRepository` / ports — **no** real Firebase or `FirebaseStorage`

---

### Slice 2 — Data

Implement **only** the data layer: models, Firebase services, repository implementation, Storage upload/delete wiring. **Depends on slice 1** domain types and contracts.

- [x] `SingleChoreModel` mirrors `photoUrl`; JSON optional field; missing key in old documents → `null`
- [x] `ChoreFirebaseService`: create single chore with a pre-generated document id when `id` is set; persist `photoUrl` in the document body when present
- [x] `ChoreFirebaseService` adds Storage-backed photo operations for `savePhoto` and `deletePhoto`; `deleteSingleChore` stays Firestore-only in the data layer
- [x] `firebase_storage` (and any Storage helper) lives in `lib/features/chores/data/datasources/remote/chore_firebase_service.dart` alongside the Firestore APIs; `ChoreRepositoryImpl` maps `savePhoto` / `deletePhoto` to those service calls, while add/delete sequencing remains in the bloc in slice 3
- [x] `pubspec.yaml`: add `firebase_storage` (and other data-only deps required for slice 2)
- [x] `storage.rules` and `firebase.json` **storage** entry (if missing): authenticated users can read/write chore photo paths used by the app; note that Storage must be enabled in the Firebase console

**TDD (data)**

- [x] `SingleChoreModel.fromJson` — `should set photoUrl to null when the json does not contain photoUrl`
- [x] `SingleChoreModel.toJson` — `should include photoUrl in json when photoUrl is present`
- [x] `ChoreRepositoryImpl.addSingleChore` / `getSingleChores` — `should propagate photoUrl between entity, model, and mocked ChoreFirebaseService`
- [x] `ChoreRepositoryImpl.savePhoto` — `should return the download url from mocked ChoreFirebaseService for the provided choreId and photoPath`
- [x] `ChoreRepositoryImpl.deletePhoto` — `should delegate photo deletion to mocked ChoreFirebaseService with the provided photoUrl`
- [ ] No widget or bloc tests in this slice — those are slice 3

**Reference — Firebase Storage (Flutter)**

Upload and persist URL (adapt paths/collections to `single_chores` and this app):

```dart
// Flutter example
final storageRef = FirebaseStorage.instance.ref('photos/user123/image1.jpg');
await storageRef.putFile(file);

final url = await storageRef.getDownloadURL();

await FirebaseFirestore.instance.collection('photos').add({
  'imageUrl': url,
  'userId': 'user123',
  'createdAt': FieldValue.serverTimestamp(),
});
```

Delete by download URL:

```dart
final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
await storageRef.delete();
```

---

### Slice 3 — Presentation

Implement **only** UI and presentation logic: bloc, screens, events/state. **Depends on slices 1–2**.

- [x] `AddSingleChoresEvent` (and related state) carries whatever the bloc needs (e.g. pre-generated chore id, optional local photo) so **`_onAddSingleChoresEvent`** calls **`SavePhoto`** then **`addSingleChore`** — see `lib/features/chores/presentation/bloc/chores_bloc.dart` (~56–69). If there is no photo, skip `SavePhoto` and only call `addSingleChore`
- [x] When deleting a single chore that has `photoUrl`, **`_onDeleteSingleChoresEvent`** (or equivalent) calls **`DeletePhoto`** (with that URL) then **`deleteSingleChore`**; if there is no `photoUrl`, only **`deleteSingleChore`**
- [x] Add-chore screen: optional **image_picker** (gallery and camera where supported); preview; loading/disabled save while work is in progress (name validation unchanged)
- [x] Single-chores tab: thumbnail or placeholder when no photo
- [x] Updating status from the list preserves `photoUrl` on the entity
- [x] `pubspec.yaml`: add `image_picker` if not already present
- [x] iOS `Info.plist` and Android manifest: permissions for photo library / camera as required by `image_picker`

**TDD (presentation)**

- [x] **Bloc tests** for `_onAddSingleChoresEvent`: with photo → `SavePhoto` then `addSingleChore` order and correct params; without photo → only `addSingleChore`; error paths emit expected states (mock use cases / repository as the project already does)
- [x] **Bloc tests** for single-chore delete: with `photoUrl` → `DeletePhoto` then `deleteSingleChore`; without `photoUrl` → only `deleteSingleChore`
- [x] Update or add **widget/golden tests** only if the project already uses them for these screens; otherwise bloc coverage is the minimum bar for this slice

---

### Slice 4 — CLI Storage Setup / Deploy

Implement **only** deployment/setup automation for Firebase Storage. **Depends on slices 1–3**. The goal of this slice is that the developer does not need to open the Firebase console for Storage setup/rules deployment during this feature workflow.

- [ ] Add a repo-owned CLI workflow (script and/or documented command entrypoint) that provisions the required Storage bucket/path configuration and deploys `storage.rules`
- [ ] The CLI workflow may use **`firebase` CLI + `gcloud` CLI**; do **not** require manual Firebase console steps for normal setup
- [ ] The CLI workflow explicitly covers: **1. activate Firebase Storage**, **2. create the required bucket**, **3. deploy `storage.rules`**
- [ ] The CLI workflow should fail with clear messages when auth, project selection, required APIs, billing plan, or IAM permissions are missing
- [ ] Keep the app/runtime feature code unchanged in this slice unless a deploy-time config hook is strictly necessary
- [ ] Document the one-command or one-sequence setup/deploy path in the repo so future setup is repeatable

**TDD / verification (cli deploy)**

- [ ] Add focused automated coverage only for any extracted, testable helper logic; if the slice is implemented as shell/CLI orchestration only, manual CLI verification is the minimum bar
- [ ] Manual verification should confirm the CLI path can **activate Storage**, **create the bucket**, and **deploy `storage.rules`** without visiting the Firebase console
