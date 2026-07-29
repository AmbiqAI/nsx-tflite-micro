# Release policy

`nsx-tflite-micro` uses SemVer and Release Please. The module version in
`nsx-module.yaml`, `version.txt`, and the Release Please manifest must remain
identical. `version.txt` is the scalar version file required by Release
Please's `simple` strategy; the YAML entry keeps the NSX catalog metadata
coherent.

## Immutable release rules

- Release tags are `vMAJOR.MINOR.PATCH` and must point to the reviewed commit
  that contains the matching module version.
- A published tag or GitHub release must never be moved or deleted.
- The source archive is generated from the exact release tag.
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
5. Merge the preparation PR using the repository's squash-merge policy.
6. After explicit maintainer approval, publish the immutable `v0.1.0` tag and
   GitHub release from the reviewed merge commit using the repository's
   controlled release procedure. The Release Please workflow is intentionally
   gated until this first tag exists.
7. Verify the tag, commit, archive, and release assets before updating any
   downstream registry pin. Subsequent versions are then derived solely from
   Conventional Commits by Release Please.

This preparation change intentionally does not publish a tag, GitHub release,
or NeuralSPOTX registry update.
