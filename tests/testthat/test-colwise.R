context("colwise mutate/summarise")

mdata <- DataFrame(score = as.integer(c(0,3,4,5,10,14,0, 0, 4,8)),
                   grp = rep(c("A", "B"), 5))

ir1 <- IRanges(start = 1:10, width = 5)
mcols(ir1) <- mdata
gr1 <- GRanges(seqnames = "seq1",
               strand = c(rep("+", 4), rep("-", 3), rep("*", 3)),
               ranges = ir1)

test_that("summarise evaluates correctly", {
  df <- DataFrame(mean = 4.8,  n = 10L)
  expect_equal(summarise(ir1, mean = mean(score), n = n()), df)
  expect_equal(summarise(gr1, mean = mean(score), n = n()), df)

  test <- ir1 %>% group_by(grp)
  gdf <- DataFrame(grp = c("A", "B"), mean = c(3.6, 6), sum = c(18L, 30L))
  expect_equal(ir1 %>% 
                 group_by(grp) %>% 
                 summarise(mean = mean(score), sum = sum(score)), 
               gdf)
  expect_equal(gr1 %>% 
                 group_by(grp) %>% 
                 summarise(mean = mean(score), sum = sum(score)), 
               gdf)

  gdf <- DataFrame(grp = c("A", "B"), n = c(5L,5L))
  expect_equal(ir1 %>% group_by(grp) %>% summarise(n = n()), gdf)
  expect_equal(gr1 %>% group_by(grp) %>% summarise(n = n()), gdf)
})

test_that("mutate allows out of scope columns", {
  gr2 <- gr1
  mcols(gr2)$score2 <- score(gr2) + 1L
  mcols(gr2)$score3 <- mcols(gr2)$score2 * 2L
  expect_identical(gr1 %>%
                     mutate(score2 = score + 1L,
                            score3 = score2*2L),
                   gr2)

  ir2 <- ir1
  mcols(ir2)$score2 <- mcols(ir2)$score*4L
  mcols(ir2)$score3 <- mcols(ir2)$score2 + 3L
  expect_identical(ir1 %>%
                     mutate(score2 = score * 4L,
                            score3 = score2 + 3L), ir2)

})

test_that("mutating by groups", {
  gr2 <- gr1
  mcols(gr2)$gt_grp_score <- (score(gr1) > 3.6 & mcols(gr1)$grp == "A") |
    (score(gr1) > 6 & mcols(gr1)$grp == "B")
  expect_identical(gr1 %>%
                     group_by(grp) %>%
                     mutate(gt_grp_score = score > mean(score)) %>%
                     ungroup(),
                   gr2)
  ir2 <- ir1
  mcols(ir2)$lt_grp_score <- (mcols(ir1)$score < 3.6 & mcols(ir1)$grp == "A") |
    (mcols(ir1)$score < 6 & mcols(ir1)$grp == "B")
  expect_identical(ir1 %>%
                     group_by(grp) %>%
                     mutate(lt_grp_score = score < mean(score)) %>%
                     ungroup(),
                   ir2)

})




test_that("mutating by groups with S4 columns", {
  S4_column <- IntegerList(
    a = NULL,
    b = c(4, 5),
    c = 3,
    d = c(2, 5),
    e = 1,
    f = c(6, 7, 8),
    g = NULL,
    h = c(5, 6),
    i = c(9, 10, 11),
    j = NULL
  )
  mcols(gr1)$exon_id <- S4_column
  mcols(ir1)$exon_id <- S4_column
  
  gr2 <- gr1
  mcols(gr2)$gt_grp_score <- (score(gr1) > 3.6 &
                                mcols(gr1)$grp == "A") |
    (score(gr1) > 6 & mcols(gr1)$grp == "B")
  expect_identical(gr1 %>%
                     group_by(grp) %>%
                     mutate(gt_grp_score = score > mean(score)) %>%
                     ungroup(),
                   gr2)
  ir2 <- ir1
  mcols(ir2)$lt_grp_score <- (mcols(ir1)$score < 3.6 &
                                mcols(ir1)$grp == "A") |
    (mcols(ir1)$score < 6 & mcols(ir1)$grp == "B")
  expect_identical(ir1 %>%
                     group_by(grp) %>%
                     mutate(lt_grp_score = score < mean(score)) %>%
                     ungroup(),
                   ir2)
  
})
