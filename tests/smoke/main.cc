#include "tensorflow/lite/micro/micro_interpreter.h"

int main() {
    const auto reset = &tflite::MicroInterpreter::Reset;
    return reset == nullptr ? 1 : 0;
}
