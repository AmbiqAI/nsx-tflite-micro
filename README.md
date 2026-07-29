# nsx-tflite-micro

`nsx-tflite-micro` exposes the Helia-RT TensorFlow Lite Micro (TFLM) runtime
through the NSX target `nsx::tflite_micro`. This repository contains the NSX
adapter only; the runtime source is supplied by the required `helia-rt-source`
module.

## Public CMake contract

The module requires these values to be defined by the NSX application before
it is added:

- `NSX_BOARD_FLAGS_TARGET`: target carrying board/compiler flags.
- `NSX_SOC_FAMILY`: selected NSX SoC family identifier.

It exports:

- `nsx::tflite_micro`: interface target containing the NSX debug-log glue and
  the selected Helia-RT runtime.

There is no module-owned C header or C API. Applications use the public TFLM
headers supplied by the pinned Helia-RT source provider.

### Configuration options

| Option | Values | Default | Meaning |
| --- | --- | --- | --- |
| `NSX_TFLITE_MICRO_BACKEND` | `reference`, `cmsis_nn` | `reference` | Selects reference kernels or standard Arm CMSIS-NN kernels. |
| `NSX_TFLITE_MICRO_VARIANT` | `debug`, `release-with-logs`, `release` | `release-with-logs` | Selects Helia-RT's TFLM build profile. |
| `TFLITE_MICRO_ROOT` | filesystem path | discovered sibling | Explicit Helia-RT source tree override. |
| `HELIA_RT_TFLM_ROOT` | filesystem path | unset | Compatibility alias for `TFLITE_MICRO_ROOT`. |
| `NSX_TFLITE_MICRO_CMSIS_NN_TARGET` | CMake target | `nsx::arm_cmsis_nn` | CMSIS-NN target supplied by `arm-cmsis-nn`. |

The adapter deliberately disables Helia's optimized `helia` backend. That
backend remains owned by the Helia-RT NSX module and must not be enabled by
this target.

## Dependencies and setup

The `helia-rt-source` module vendors the Helia-RT checkout beside this module,
so source discovery works in a normal NSX application. An explicit source
override is also supported:

```text
-DTFLITE_MICRO_ROOT=/path/to/helia-rt
```

The `reference` backend has no additional kernel dependency. For
`cmsis_nn`, add `arm-cmsis-nn` before this module; it exports
`nsx::arm_cmsis_nn`. Its source locations can be overridden with
`ARM_CMSIS_NN_ROOT` and, when needed, `ARM_CMSIS_ROOT`:

```text
-DNSX_TFLITE_MICRO_BACKEND=cmsis_nn
```

## Supported compatibility surface

| Surface | Support |
| --- | --- |
| Kernel backends | Reference; standard Arm CMSIS-NN |
| Ambiq Helia backend | Not selected by this module |
| NSX platform | AmbiqSuite through `nsx-soc-hal` |
| Boards and SoCs | Delegated to the selected NSX board/SoC modules |
| Toolchains | `arm-none-eabi-gcc`, Arm Compiler 6 (`armclang`), ATfE |
| Zephyr | Not supported by this adapter |

The toolchain and backend declarations describe the supported integration
surface. Device-specific qualification, operator coverage, and performance
claims remain responsibilities of the pinned Helia-RT and CMSIS-NN sources.
The immutable dependency identities used for the initial release are recorded
in [PROVENANCE.md](PROVENANCE.md).

## Profiling

The runtime retains Helia-RT's `MicroProfilerInterface` API. Consumers can use
the stock TFLM `MicroInterpreter` integration with a profiler implementation
provided by their application or by a compatible Helia Profiler release.
