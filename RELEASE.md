# Release policy

`nsx-tflite-micro` uses SemVer and Release Please for release PRs. A separate
controlled publisher creates tags and releases only after CI. The module version in
`nsx-module.yaml`, `version.txt`, and the Release Please manifest must remain
identical. `version.txt` is the scalar version file required by Release
Please's `simple` strategy; the YAML entry keeps the NSX catalog metadata
coherent.

## Immutable release rules

- Release tags are annotated `vMAJOR.MINOR.PATCH` tags whose peeled target is
  the reviewed commit containing the matching module version.
- A published tag or GitHub release must never be moved or deleted.
- The source archive is generated from the exact release tag.
- Manual archive rebuilds are allowed only after the tagged commit has a
  successful hosted CI run.
- Dependency revisions are recorded in the downstream registry; changing a
  dependency pin is a separate NeuralSPOTX change and is not part of this
  module release.
- Release automation may create tags and releases only after the preparation
  pull request has passed CI and received explicit maintainer approval.

## First-release checklist

1. Confirm the module version, changelog entry, license, and provenance table.
2. Verify reference-backend host build/link and available Arm cross-build
   smokes.
3. Verify the CMSIS-NN configuration contract with the pinned external target.
4. Review the generated release notes and dependency identities.
5. Treat hosted CMake smokes as structural checks only; review the local
   cross-build evidence and deferred ATfE/hardware qualification in the
   compatibility documentation.
6. Merge the preparation PR using the repository's squash-merge policy.
7. After explicit maintainer approval, publish the annotated immutable
   `v0.1.0` tag and GitHub release from the reviewed PR #2 merge commit using
   the repository's    controlled release procedure. The Release Please PR workflow is
   intentionally gated until this exact tag/commit/metadata tuple exists.
8. Verify the tag, commit, archive, and release assets before updating any
   downstream registry pin. Subsequent versions are derived from Conventional
   Commits by Release Please, then published by the CI-gated controlled
   publisher.

This preparation change intentionally does not publish a tag, GitHub release,
or NeuralSPOTX registry update.
