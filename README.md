# nsx-tflite-micro

This module exposes Helia-RT's TFLM runtime as `nsx::tflite_micro` without
selecting the Ambiq `helia` backend. It supports:

- `NSX_TFLITE_MICRO_BACKEND=reference`
- `NSX_TFLITE_MICRO_BACKEND=cmsis_nn`

The source tree is resolved from a sibling `helia-rt` checkout by default, or
from `-DTFLITE_MICRO_ROOT=/path/to/helia-rt`.

For standard CMSIS-NN, add the `arm-cmsis-nn` module before this module. The
wrapper exports `nsx::arm_cmsis_nn`; set `ARM_CMSIS_NN_ROOT` and, when needed,
`ARM_CMSIS_ROOT` to the upstream Arm checkouts. Then configure:

```text
-DNSX_TFLITE_MICRO_BACKEND=cmsis_nn
```

The runtime keeps Helia-RT's `MicroProfilerInterface` API, so helia-profiler
can provide its existing per-layer profiler implementation directly through
the `MicroInterpreter` constructor.
