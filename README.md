# Improving Five-Star Ratings

## Introduction

The five-star ratings system is used across the internet to give customers a familiar, quantitative metric to base their decisions on. Having a ratings system that customers trust to provide an accurate metric into the quality of a product is absolutely critical for web-based companies. Unfortunately, the five-star ratings system suffers from several problems. This project will address these problems by applying an Item Response Theory model to better measure the ability of restaurants to satisfy their customers.

**The Question:** Can I build a five-star review system that more accurately communicates the quality of a product to the customer?

**The Data:** Yelp Open Dataset (11.73 GB)

**The Approach:** Bayesian item response theory modelling

## Why Do We Use Five-Star Reviews?

The five-star ratings system is useful because it is familiar: it is widely adopted and any internet user immediately understands what the five stars represent without further explanation. The five-star metric is quantitative but simple enough to convey a sense of "quality" to the customer, without providing an overwhelming amount of information.

## Flaws In The System

However, there are a few flaws with the five-star review system as it is usually implemented. 

1. All reviews are weighted the same for a product, and the quality of each reviewer is assumed to be the same. This can cause significant bias and allows for ratings manipulation by bad actors. 
2. Users that have strong feelings (positive or negative) about a product are more likely to take the time to write a review, which provides a biased view of the product. 
3. There is a positivity bias in reviews - there are more positive reviews than negative reviews.
4. Products with many reviews have similar ratings. Taken together with the positivity bias in reviews, most business or products have an aggregate score of 3-4.5 stars. For example, a product with a 4.6-star rating may be much better than a product with a 4.4-star rating, but the difference in the number of stars doesn't give the customer much information. It is hard to separate the good from the great.
5. New restaurants suffer from a 'cold start,' where the first review they receive is too little information to build an accurate rating.

This plot shows the variance of each reviewer's ratings. If a reviewer only gives five-star reviews, then there is zero variance in their reviews. If a reviewer gives mostly one- and five-star reviews, then they will have a variance around 4. This shows that many reviewers have a small variance, and it might be worthwhile to weight reviewers with a larger variance higher.

![](/figures/reviewer_variance.png)

The two plots below show the number of reviews that give a certain star rating and the number of restaurants that have a certain rating, respectively. These plots highlight the challenges described in points two through four.

![](/figures/ratings_dist.png)


## A Better Model

In this project, I will use an Item Response Theory (IRT) model to assess the ability of restaurants in the Yelp dataset to satisfy their customers. Traditionally, IRT models are used to measure the latent trait of intelligence based on the responses of several students to several different questions. In this application, I will use an IRT model to measure the latent ability of restaurants to satisfy their customer based on how well a collection of restaurants is reviewed by several customers.

Mathematically, if the quality of restaurant *i* is *alpha_i*, the mean restaurant quality is *delta*, and the difficulty of pleasing reviewer *j* is *beta_j*, then a binary IRT model can be expressed as:

*y_ij ~* Bernoulli *(alpha_i - beta_j + delta)*

where *y_ij* is the predicted review of reviewer *j* for restaurant *i*, where 1 is a good review, and 0 is a bad review.

## Building a New Review System

Solving the IRT model gives access to the parameter *alpha*, which is a new measure of the quality of a restaurant. Compared with the old measure of quality - the mean of the reviews - *alpha* accounts for the variability of reviewer difficulty by adding in the parameter *beta*. This addresses the first flaw by weighting each reviewer by how well they can tell good restaurants from bad restaurants.

Addressing flaw two can be done by including assumptions about how often people right reviews and modelling the nonresponse of mediocre reviews.

Flaws three and four can be handled together by redistributing the final distribution of reviews. For example, on the right plot of figure 2, the reviews are a skew-left distribution with a peak at about 3.8 stars. This could be redistributed to be a uniform distribution.

Finally, I will use Bayesian methods to handle uncertainty in restaurant quality. This will help solve flaw five by accepting that a single review cannot give enough information to build a confident rating.

## Progress on a Bayesian IRT Model

To begin, I have isolated restaurants and their reviews from the Yelp dataset that are in Colorado. This dataset reduction allows for fast iteration. A key goal of this project is to run the model on the entire Yelp dataset.

I have built a binary, Bayesian, one-parameter logistic IRT model using the probabilistic programing language Stan. The model samples efficiently and converges well.

To explore how the IRT model behaves differently than just looking at the mean values of each review, I'll explore the result of the model for two restaurants, A and B. First, We can look at the distribution of reviews for restaurants A and B.

![](/figures/dist_reviews_AB.png)

From looking at these distributions, I would expect restaurant A to have a higher overall rating, and it does, coming in at 4.5 stars, while restaurant B has 4.0 stars. But that’s not the entire story, how difficult to please were the reviewers of Restaurant A and B? We can assess this by comparing the distributions of the average score that the reviewers of Restaurant A and B gave to all restaurants they had been to.

![](/figures/dist_avg_user_reviews.png)

While the difference in the distributions may look small, it is actually quite significant. Restaurant B had diners that were much harder to please on average than restaurant A. Knowing this, would I confidently assert that restaurant A is better than restaurant B? I'm not so sure. 

The IRT model, which accounts for the difficulty of the reviewers, actually thinks restaurant B is of higher quality. The IRT model believes that restaurant B is 2.4 standard deviations better than average, while restaurant A is 1.3 standard deviation above average.

## Speeding It Up

Markov chain Monte Carlo (MCMC) Bayesian sampling methods are notoriously slow - too slow for a dataset of this size. The final version of this project will use variational Bayesian (VB) methods to approximate MCMC sampling. Variational Bayes is a large class of methods - each with its pros and cons. I have explored how well variational Bayes works on IRT models by running both VB and MCMC. The results show that while parameter estimates may be close, VB significantly underestimates the variance of the parameter estimates. Below is a plot exploring how well parameter estimates for $\alpha$ align for a sampling of twenty restaurants.

![](/figures/mcmc_vb_comparison.png)

Again, the variance of the parameters is highly biased with the VB estimation, and the accuracy begins to fall when the parameter estimate is far from zero. However, the speed increase is massive. A significant portion of this project will revolve around understanding the tradeoffs between MCMC and VB, and how the differences affect how my alternative model can improve upon the old five-star rating system.


## Future Work

This is only a preliminary demonstration of what I aim to accomplish with this project. In rough order of importance, my future work will include:

1. Finding a metric that plausibly measures the improvement of my IRT-based review system over the classic system.
2. Building an app or other demonstration that highlights the difference between my IRT approach and the old approach to five-star ratings.
3. Working on communicating how the IRT model works and solves flaw one.
4. Figuring out how to include the variance of the Bayesian posterior into the five-star rating in order to address flaw five.
5. Building a redistributing pipeline to address flaws two through four.
6. Optimizing the variational Bayes model and running on the full Yelp dataset.
7. Including a regression term for $\beta$ to include aggregate linguistic properties of the reviews.
8. Finding a more interesting/complete/unique or better fitting dataset than Yelp.


























