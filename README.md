# Oil Spills detection and Segmentation in SAR images


![GitHub watchers](https://img.shields.io/github/watchers/d-elicio/Oil-Spill-Detection-in-SAR-images?style=social)
![GitHub forks](https://img.shields.io/github/forks/d-elicio/Oil-Spill-Detection-in-SAR-images?style=social)
![GitHub User's stars](https://img.shields.io/github/stars/d-elicio?style=social)
![GitHub last commit](https://img.shields.io/github/last-commit/d-elicio/Oil-Spill-Detection-in-SAR-images)

Design and implementation of Image Processing segmentation
techniques and algorithms for oil spill detection on SAR images
## 🚀 About Me
I'm a computer science Master's Degree student and this is one of my university project. 
See my other projects here on [GitHub](https://github.com/d-elicio)!

[![portfolio](https://img.shields.io/badge/my_portfolio-000?style=for-the-badge&logo=ko-fi&logoColor=white)](https://d-elicio.github.io)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/domenico-elicio/)


# 💻 The project

- The project consists in the designing and implementation of Image Processing techniques and algorithms used for the **detection** and **segmentation** of oil spills on **SAR (Synthetic Aperture Radar)** images
- To verify the **correctness** and the **precision** of these implemented methods, our segmented images have been compared to the **ground truth** masks in the dataset used in this [article](https://www.researchgate.net/publication/334715725_Oil_Spill_Identification_from_Satellite_Images_Using_Deep_Neural_Networks)
- Ground truth masks are divided into **5** different classes, each with a specific RGB color: *cyan* for the oil spills, *red* for look-alikes, *brown* for ships, *green* for land and *black* for sea surface.  
- In this work the produced masks have only three RGB colors: **black** for sea surface, **green** for lands and **cyan** for oil spills.
- Different image segmentation techniques have been implemented to compare various approaches, their segmentation effectiveness, their execution times, and their behavior with different types of images (different light conditions, different noise, etc..)

![Immagine 2022-08-06 185958](https://user-images.githubusercontent.com/96207365/183258716-74fe57a6-8c97-4d98-97e3-ff2ea7b8d79a.jpg)

### Segmentation methods implemented:
- **Thresholding segmentation**
    - *Manual Thresholding*
    - *Automatic Thresholding*
    - *Local Adaptive Thresholding*
- **Superpixel approach**
- **Fuzzy Logic approach**
- **K-means clustering**
- **Land masking**  

## Description

- The used SAR dataset is composed of two types of images: images with *only sea* surface and *one or multiple oil spills* and images with *lands, sea, and oil spills.* In this work two different approaches were followed based on the type of image analyzed:
    - Images with **land and sea** are analyzed by using *two methods*: an **automatic thresholding** method and a **k-means clustering approach**
    - Images with **only sea and oil spills** are instead analyzed using *four different approaches*: a **thresholding method**, with three different thresholding variants (*manual, automatic and a local adaptive threshold*), a **superpixel approach**, an **edge detection** of oil spills through a **Fuzzy Logic approach** and **k-means clustering** to identify similar regions and create the oil spill segmentation mask.

- Different image enhancement techniques like **median** or **Wiener filters** and **histogram equalization** techniques have been used.
![Immagine 2022-08-06 190351](https://user-images.githubusercontent.com/96207365/183258816-0881c834-f437-41d3-a101-a8582dba555a.jpg)

- Lots of algorithms used (like the superpixels technique) have a final phase of **dark spot feature extraction** to select, between all the extracted blobs, only those who satisfy some conditions to create the final **binary mask**.
![Immagine 2022-08-06 190732](https://user-images.githubusercontent.com/96207365/183258954-a0a04656-32d4-42a1-9884-b0668dc1b379.jpg)

- For **k-means clustering** also a visual representation with different colors for every cluster is provided.
![Immagine 2022-08-06 191116](https://user-images.githubusercontent.com/96207365/183259085-7a9be686-348b-4d3c-b775-c34ce0133a80.jpg)


## Results
- Every segmentation produced by the implemented methods in this work are evaluated both *qualitatively* by comparing the ground truth and the final segmented images, and *quantitatively* by using three different evaluation metrics: **Jaccard Index**, **Sørensen-Dice similarity** and **BF score**. 

- For every computed metric a comparison between segmentation results and the ground truth is shown (three colors are used: ***green*** stands for the ground truth, ***white*** represents all our segmentation results that match correctly the ground truth area and ***violet*** stands for all our segmentation results which are not present in the ground truth label).

![evaluation indices](https://user-images.githubusercontent.com/96207365/185741928-d8a9379d-d6f7-490b-8694-4d1b32435daf.jpg)

- These three indices are a good starting point to evaluate the goodness of segmentation methods used, but during the development of this project, lots of times have been seen that *also ground truth mask have exaggeratedly large borders with respect to the original SAR image*, in particular for oil spills, so together with this evaluation parameters, also a final image representing the original SAR image with the overlapped segmentation mask has been produced, to *qualitatively* judge too the segmentation results. 

![img3 sovrapposta mask](https://user-images.githubusercontent.com/96207365/185742093-b89e98e3-aa9e-43fa-9b67-394317a99cc7.jpg)

- Obviously, some methods are better than others and this depends on the *image quality*, the *presence of noise*, the *total brightness* of the image, the *overall contrast*, etc., but **the user can modify some parameters** for every method **to improve segmentation results**.

### Documentation

- To understand better the code of this segmentation project please see the [code explanation file](https://github.com/d-elicio/Oil-Spill-Detection-in-SAR-images/blob/main/Code%20explanation%20(technical%20implementation).pdf).

## Support

For any support, error corrections, etc. please email me at domenico.elicio13@gmail.com

