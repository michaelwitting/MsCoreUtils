test_that("aggregation: medianPolish", {
    ## numerical example taken from ?stats::medpolish
    x <- rbind(c(14,15,14),
               c( 7, 4, 7),
               c( 8, 2,10),
               c(15, 9,10),
               c( 0, 2, 0))
    colnames(x) <- LETTERS[1:3]
    rownames(x) <- paste0("pep", 1:5)
    x2 <- medianPolish(x)
    expect_is(x2, "numeric")
    expect_identical(length(x2), ncol(x))
    mp <- stats::medpolish(x, trace.iter = FALSE)
    ## Check decomposition
    expect_identical(x, mp$overall + outer(mp$row, mp$col, "+") + mp$residuals)
    expect_identical(names(x2), colnames(x))
})


test_that("aggregation: robustSummary", {
    ## numeric example taken from `MSnbase::combineFeatures` on
    ## `log(filterNA(msnset), 2)`
    x <- structure(c(10.3961935744407, 10.6379251053134,
                     7.52885076885599, 11.1339832690524,
                     11.5154097311056, 7.69906817878979,
                     11.9394664781386, 12.2958526883634,
                     9.00858488668671, 12.9033445520186,
                     13.3390344671153, 9.75719265786117),
                   .Dim = 3:4,
                   .Dimnames = list(c("X1", "X52", "X53"),
                                    c("iTRAQ4.114", "iTRAQ4.115",
                                      "iTRAQ4.116", "iTRAQ4.117")))
    x2_expected <- c(iTRAQ4.114 = 9.52098981620336, iTRAQ4.115 = 10.1620299826269, 
                     iTRAQ4.116 = 11.0813013510629, iTRAQ4.117 = 11.999857225665)
    x2 <- robustSummary(x)
    expect_equal(x2, x2_expected)
})

test_that("aggregation: robustSummary", {
    x <- structure(c(10.3961935744407, 10.6379251053134,
                     7.52885076885599, 11.1339832690524,
                     11.5154097311056, 7.69906817878979,
                     11.9394664781386, 12.2958526883634,
                     9.00858488668671, 12.9033445520186,
                     13.3390344671153, 9.75719265786117),
                   .Dim = 3:4)
    expect_error(robustSummary(x), "colnames must not be empty")
})

test_that("aggregation: aggregate_by_vector", {
    ## Numeric example taken from `MSnbase::combineFeatures` on
    ## `log(filterNA(msnset), 2)`
    x <- structure(c(3.37798349666944, 4.10151322208566, 3.81790550688852, 
                     3.68373564094019, 3.41114487991947, 2.91242966348861, 1.97017675008189, 
                     3.47689791527908, 4.04720220698125, 3.82566260214081, 3.57800373068237, 
                     3.525493839628, 2.94468384643243, 1.98947385475541, 3.57766646528063, 
                     3.94290011925067, 3.83197127627519, 3.48680275001825, 3.6200998807866, 
                     3.17130049812522, 1.93779683012642, 3.68967315613391, 3.84557183862662, 
                     3.82393074128306, 3.33967874492785, 3.73758233712817, 3.28646611488044, 
                     1.92996581207855),
                   .Dim = c(7L, 4L), 
                   .Dimnames = list(c("X1", "X27", "X41", "X47", "X52",
                                      "X53", "X55"),
                                    c("iTRAQ4.114", "iTRAQ4.115", 
                                      "iTRAQ4.116", "iTRAQ4.117")))
    ## Different ways to provide INDEX
    k_char <- c("B", "E", "X", "E", "B", "B", "E")
    k_fact <- factor(k_char)
    k_fact2 <- factor(k_char, levels = c("X", "E", "B"))
    ## Harmonise row names for comparison - these can change based on
    ## the different levels.
    same_row_names <- c("B", "E", "X")

    ## aggregate: robustSummary
    x2_robust_expected <- 
        structure(c(3.23385268002584, 3.27016773304649,
                    3.81790550688852, 3.33557123434545,
                    3.20489326413968, 3.82566260214081,
                    3.45635561473081, 3.12249989979845,
                    3.83197127627519, 3.57124053604751,
                    3.01422698197221, 3.82393074128306),
                  .Dim = 3:4,
                  .Dimnames = list(c("B", "E", "X"),
                                   c("iTRAQ4.114", "iTRAQ4.115",
                                     "iTRAQ4.116", "iTRAQ4.117")))
    ## Test for different INDEX types and order
    expect_equal(x2_robust_expected[same_row_names, ],
                 aggregate_by_vector(x, k_char, robustSummary)[same_row_names, ])
    expect_equal(x2_robust_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact, robustSummary)[same_row_names, ])
    expect_equal(x2_robust_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact2, robustSummary)[same_row_names, ])

    ## aggregate: medianPolish
    x2_medpolish_expected <- 
        structure(c(3.36717083720277, 3.63886529932001,
                    3.81790550688852, 3.47689791527908,
                    3.57800373068237, 3.82566260214081,
                    3.57766646528063, 3.48680275001825,
                    3.83197127627519, 3.69360829441147,
                    3.38292391586096, 3.82393074128306),
                  .Dim = 3:4,
                  .Dimnames = list(c("B", "E", "X"),
                                   c("iTRAQ4.114", "iTRAQ4.115",
                                     "iTRAQ4.116", "iTRAQ4.117")))
    ## Test for different INDEX types and order
    expect_equal(x2_medpolish_expected[same_row_names, ],
                 aggregate_by_vector(x, k_char, medianPolish)[same_row_names, ])
    expect_equal(x2_medpolish_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact, medianPolish)[same_row_names, ])
    expect_equal(x2_medpolish_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact2, medianPolish)[same_row_names, ])

    ## aggregate: sum
    x2_sum_expected <-
        structure(c(9.70155804007753, 9.75542561310774,
                    3.81790550688852, 9.94707560133951,
                    9.61467979241903, 3.82566260214081,
                    10.3690668441924, 9.36749969939534,
                    3.83197127627519, 10.7137216081425,
                    9.11521639563303, 3.82393074128306),
                  .Dim = 3:4,
                  .Dimnames = list(c("B", "E", "X"),
                                   c("iTRAQ4.114", "iTRAQ4.115",
                                     "iTRAQ4.116", "iTRAQ4.117")))
    ## Test for different INDEX types and order
    expect_equal(x2_sum_expected[same_row_names, ],
                 aggregate_by_vector(x, k_char, colSums)[same_row_names, ])
    expect_equal(x2_sum_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact, colSums)[same_row_names, ])
    expect_equal(x2_sum_expected[same_row_names, ],
                 aggregate_by_vector(x, k_fact2, colSums)[same_row_names, ])

})
