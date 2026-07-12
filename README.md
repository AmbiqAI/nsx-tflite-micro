# nsx-tflite-micro

This module exposes Helia-RT's TFLM runtime as `nsx::tflite_micro` without
selecting the Ambiq `helia` backend. It supports:

- `NSX_TFLITE_MICRO_BACKEND=reference`
- `NSX_TFLITE_MICRO_BACKEND=cmsis_nn`

The required `helia-rt-source` module vendors Helia-RT beside this module, so
the source tree resolves automatically in an NSX app. An explicit
`-DTFLITE_MICRO_ROOT=/path/to/helia-rt` still overrides that default.

For standard CMSIS-NN, add the `arm-cmsis-nn` module before this module. The
separate module exports `nsx::arm_cmsis_nn`; its bundled upstream sources are
used by default. Set `ARM_CMSIS_NN_ROOT` and, when needed, `ARM_CMSIS_ROOT` to
override those source locations. Then configure:

```text
-DNSX_TFLITE_MICRO_BACKEND=cmsis_nn
```

The runtime keeps Helia-RT's `MicroProfilerInterface` API. Helia Profiler can
use it through its stock TFLM engine integration once the corresponding
NeuralSPOTX registry and Helia Profiler releases are available.
