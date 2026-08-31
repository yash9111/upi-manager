import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

class StressConfig {
  final int matrixSize;
  final int iterations;

  StressConfig(this.matrixSize, this.iterations);
}

void cpuWorker(StressConfig config) {
  final size = config.matrixSize;
  final random = Random();

  final A = Float64List(size * size);
  final B = Float64List(size * size);
  final C = Float64List(size * size);

  // Fill matrices
  for (int i = 0; i < A.length; i++) {
    A[i] = random.nextDouble();
    B[i] = random.nextDouble();
  }

  for (int iteration = 0;
      iteration < config.iterations;
      iteration++) {

    // Matrix multiplication
    for (int i = 0; i < size; i++) {
      final rowStart = i * size;

      for (int k = 0; k < size; k++) {
        final a = A[rowStart + k];
        final bRowStart = k * size;

        for (int j = 0; j < size; j++) {
          C[rowStart + j] +=
              a * B[bRowStart + j];
        }
      }
    }

    // Heavy mathematical operations
    for (int i = 0; i < C.length; i++) {
      final value = C[i];

      C[i] =
          sin(value) +
          cos(value) -
          sqrt(value.abs());
    }

    print(
      'Isolate ${Isolate.current.hashCode}: '
      'completed iteration ${iteration + 1}',
    );
  }

  print(
    'Isolate ${Isolate.current.hashCode}: DONE',
  );
}

Future<void> main() async {
  final stopwatch = Stopwatch()..start();


  const workers = 18;


  const matrixSize = 4000;

  const iterations = 10;

  print('======================================');
  print('       DART CPU + RAM STRESS TEST');
  print('======================================');
  print('Workers      : $workers');
  print('Matrix       : $matrixSize x $matrixSize');
  print('Iterations   : $iterations');
  print('');
  print('Starting test...');
  print('');

  final isolates = <Future>[];

  for (int i = 0; i < workers; i++) {
    isolates.add(
      Isolate.spawn(
        cpuWorker,
        StressConfig(matrixSize, iterations),
      ),
    );
  }

  await Future.wait(isolates);

  stopwatch.stop();

  print('');
  print('======================================');
  print('TEST COMPLETED');
  print('Time: '
      '${stopwatch.elapsedMilliseconds / 1000} seconds');
  print('======================================');
}