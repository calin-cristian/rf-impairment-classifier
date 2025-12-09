# **RF Constellation Impairment Classification**

This repository contains a complete workflow for training a neural network to classify RF impairments directly from baseband I/Q constellation samples. It includes the raw captured data from PlutoSDRs, the MATLAB script that generates the labeled dataset, and the notebook used to train and evaluate the model.

The project is useful for link-quality monitoring, automated receiver diagnostics, and SDR research workflows where distorted frames should be identified or discarded before analysis.

---

## **Repository Contents**
* RF_Impairment_Classification.ipynb # Training notebook (Colab/Jupyter)
* datasetAug.m # MATLAB augmentation script



---

## **Overview**

A QPSK signal was transmitted between two PlutoSDRs placed close together to obtain a clean baseline constellation.  
The receiver performed standard DSP operations (AGC, filtering, synchronization) and output one `symFrame` per detected frame, stored in `rxData_QPSK.mat`.

To create a supervised learning dataset, synthetic impairments were applied to each clean frame in MATLAB:

- **Low SNR** (AWGN)
- **Carrier Frequency Offset** (CFO)
- **Static phase offset**
- **Timing distortion / ISI**
- **IQ imbalance**

Each augmented frame is assigned a label:
0 = clean
1 = low SNR
2 = CFO residual
3 = static phase offset
4 = timing distortion
5 = IQ imbalance


The full dataset (`datasetQPSK.mat`) contains:

- `Xmat` — complex constellation samples `(Nsym × N_total)`
- `yvec` — class labels `(N_total,)`
- `Nsym, N_total` — dataset dimensions

---

## **Reproducing the Dataset**

1. Place `rxData_QPSK.mat` and `datasetAug.m` in the same directory.  
2. Open MATLAB.  
3. Run:

```matlab
datasetAug


