//
//  FFTProcessor.swift.swift
//  GuitarTunerApp
//
//  Created by Negi on 21/06/26.
//


import Accelerate


// MARK:  takes 1024 samples → Hanning window → FFT → returns 512 magnitude bins

final class FFTProcessor {

    private let fftSize: Int
    private let log2n: vDSP_Length
    private let fftSetup: FFTSetup
    private var window: [Float]

    init(fftSize: Int = 1024) {
        self.fftSize = fftSize
        self.log2n = vDSP_Length(log2(Float(fftSize)))
        self.fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!

        // Precompute the Hanning window once — reused every call
        self.window = [Float](repeating: 0, count: fftSize)

        vDSP_hann_window(
            &self.window,
            vDSP_Length(fftSize),
            Int32(vDSP_HANN_NORM)
        )
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }

    /// Returns magnitude spectrum — one value per frequency bin
    func magnitudes(of samples: [Float]) -> [Float] {

        guard samples.count == fftSize else {
            return []
        }

        // Step 1 — apply the Hanning window
        var windowed = [Float](repeating: 0, count: fftSize)

        vDSP_vmul(
            samples,
            1,
            window,
            1,
            &windowed,
            1,
            vDSP_Length(fftSize)
        )

        // Step 2 — split into real/imaginary halves
        var realp = [Float](repeating: 0, count: fftSize / 2)
        var imagp = [Float](repeating: 0, count: fftSize / 2)
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)

        realp.withUnsafeMutableBufferPointer { realPtr in
            imagp.withUnsafeMutableBufferPointer { imagPtr in

                var splitComplex = DSPSplitComplex(
                    realp: realPtr.baseAddress!,
                    imagp: imagPtr.baseAddress!
                )

                windowed.withUnsafeBufferPointer { ptr in
                    ptr.baseAddress!.withMemoryRebound(
                        to: DSPComplex.self,
                        capacity: fftSize / 2
                    ) { complexPtr in

                        vDSP_ctoz(
                            complexPtr,
                            2,
                            &splitComplex,
                            1,
                            vDSP_Length(fftSize / 2)
                        )
                    }
                }

                // Step 3 — run the actual transform
                vDSP_fft_zrip(
                    fftSetup,
                    &splitComplex,
                    1,
                    log2n,
                    FFTDirection(FFT_FORWARD)
                )

                // Step 4 — convert real/imaginary pairs to magnitude per bin
                vDSP_zvmags(
                    &splitComplex,
                    1,
                    &magnitudes,
                    1,
                    vDSP_Length(fftSize / 2)
                )
            }
        }

        return magnitudes
    }
}
