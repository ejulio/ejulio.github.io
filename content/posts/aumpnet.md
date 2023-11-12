---
date: 2017-06-03
title: "AUMPNet: Simultaneous Action Units Detection and Intensity Estimation on Multipose Facial Images Using a Single Convolutional Neural Network"
authors: ["Júlio César Batista", "Vítor Albiero", "Olga R. P. Bellon", "Luciano Silva"]
tags: ["Publicação"]
---

**Abstract**: This paper presents an unified convolutional neural network (CNN), named AUMPNet, to perform both Action Units (AUs) detection and intensity estimation on facial images with multiple poses. Although there are a variety of methods in the literature designed for facial expression analysis, only few of them can handle head pose variations. Therefore, it is essential to develop new models to work on non-frontal face images, for instance, those obtained from unconstrained environments. In order to cope with problems raised by pose variations, an unique CNN, based on region and multitask learning, is proposed for both AU detection and intensity estimation tasks. Also, the available head pose information was added to the multitask loss as a constraint to the network optimization, pushing the network towards learning better representations. As opposed to current approaches that require ad hoc models for every single AU in each task, the proposed network simultaneously learns AU occurrence and intensity levels for all AUs. The AUMPNet was evaluated on an extended version of the BP4D-Spontaneous database, which was synthesized into nine different head poses and made available to FG 2017 Facial Expression Recognition and Analysis Challenge (FERA 2017) participants. The achieved results surpass the FERA 2017 baseline, using the challenge metrics, for AU detection by 0.054 in F1-score and 0.182 in ICC(3, 1) for intensity estimation.

In *2017 12th IEEE International Conference on Automatic Face & Gesture Recognition* (FG'17).

https://ieeexplore.ieee.org/document/7961834/