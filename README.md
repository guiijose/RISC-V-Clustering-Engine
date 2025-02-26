# K-Means Clustering in RISC-V Assembly

## Overview
This project implements the K-Means clustering algorithm in **RISC-V assembly**, demonstrating low-level programming techniques for machine learning applications. The implementation groups data points into clusters based on their feature similarity, a fundamental task in unsupervised learning.

## Features
- **Fully implemented in RISC-V assembly**
- **Efficient use of registers and memory** for clustering operations
- **Fixed-point arithmetic** to handle computations without floating-point operations
- **Optimized looping and branching** for performance

## Project Structure
```
.
├── k-means.s   # RISC-V assembly implementation of K-Means
├── README.md   # Project documentation
```

## Compilation and Execution
To assemble and run the program using **Ripes**, a RISC-V simulator:
1. Open **Ripes**.
2. Load `k-means.s` into the assembler.
3. Assemble the program and run it step by step or continuously.
4. Observe register and memory changes during execution.

## How It Works
1. **Data Initialization**: Points and centroids are loaded into memory.
2. **Assignment Step**: Each point is assigned to the nearest centroid.
3. **Update Step**: New centroids are computed based on the average of assigned points.
4. **Loop Until Convergence**: Steps 2 and 3 repeat until centroids no longer change.

## Contact
For any inquiries regarding this project, feel free to reach out.

---
This project showcases **low-level algorithm implementation** and **performance optimization in RISC-V assembly**.

This project was developed for the **Introduction to Computer Architecture** course at **Instituto Superior Técnico (IST)**.

