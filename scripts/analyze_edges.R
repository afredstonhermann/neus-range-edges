library(here)
library(tidyverse)
library(purrr)
library(broom)

# add in lat analysis too? to compare/contrast

poldat.stats <- readRDS(here("processed-data","poldat.stats.rds"))
eqdat.stats <- readRDS(here("processed-data","eqdat.stats.rds"))


#################
# LM: edge ~ time 
#################


poldat.lm <- poldat.stats %>% 
  dplyr::select(latinname, commonname, spp.dist95, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(spp.dist95 ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

poldat.corr <- poldat.stats %>% 
  dplyr::select(commonname, spp.dist95, year) %>% 
  distinct() %>% 
  nest(-commonname) %>% 
  mutate(
    test = map(data, ~ cor.test(.x$spp.dist95, .x$year, method="spearman")),
    tidied = map(test, tidy)) %>% 
  unnest(tidied, .drop=TRUE) 

poldat.assemblage.lm <- poldat.stats %>% 
  dplyr::select(year, assemblage.dist95) %>% 
  distinct() %>% 
  lm(assemblage.dist95 ~ year, data = .) %>% 
  summary()

eqdat.lm <- eqdat.stats %>% 
  dplyr::select(latinname, commonname, spp.dist05, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(spp.dist05 ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

eqdat.corr <- eqdat.stats %>% 
  dplyr::select(commonname, spp.dist05, year) %>% 
  distinct() %>% 
  nest(-commonname) %>% 
  mutate(
    test = map(data, ~ cor.test(.x$spp.dist05, .x$year, method="spearman")),
    tidied = map(test, tidy)) %>% 
  unnest(tidied, .drop=TRUE) 

eqdat.assemblage.lm <- eqdat.stats %>% 
  dplyr::select(year, assemblage.dist05) %>% 
  distinct() %>% 
  lm(assemblage.dist05 ~ year, data = .) %>% 
  summary() 


#################
# LM: depth ~ time 
#################

poldat.depth.lm <- poldat.stats %>% 
  dplyr::select(latinname, commonname, depth.mean.wt, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(depth.mean.wt ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

eqdat.depth.lm <- eqdat.stats %>% 
  dplyr::select(latinname, commonname, depth.mean.wt, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(depth.mean.wt ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

#################
# LM: abundance ~ time 
#################

poldat.abund.lm <- poldat.stats %>% 
  dplyr::select(latinname, commonname, biomass.sum, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(biomass.sum ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

eqdat.abund.lm <- eqdat.stats %>% 
  dplyr::select(latinname, commonname, biomass.sum, year) %>% 
  distinct() %>% 
  group_by(commonname) %>% 
  nest() %>% 
  mutate(
    model = map(data, ~lm(biomass.sum ~ year, data = .x)), 
    tidymodel = map(model, tidy)
  ) %>% 
  unnest(tidymodel, .drop=TRUE) %>% 
  filter(term=="year")

#################
# GLM: edge ~ temperature 
#################

#################
# Make Figure 1
#################

#################
# Make Figure 2 
#################

pol.lm.gg <- poldat.lm %>% 
  filter(term=="year") %>% 
  arrange(estimate) %>% 
  mutate(commonname=factor(commonname, unique(commonname)),
         signif=ifelse(p.value<=0.05, "yes","no")) %>% 
  ggplot(aes(x=commonname, y=estimate, ymin=(estimate-std.error), ymax=(estimate+std.error), color = signif, fill=signif)) + 
  geom_pointrange() + 
  scale_colour_manual(values=c("yes" ="#EAAE58","no" = "#37AD97")) + 
  geom_hline(yintercept=0) +
  labs(x=NULL, y="Est. Effect of Year on Edge Position (m)", title="Poleward Edge Assemblage") +
  coord_flip() +
  NULL
pol.lm.gg

eq.lm.gg <- eqdat.lm %>% 
  filter(term=="year") %>% 
  arrange(estimate) %>% 
  mutate(commonname=factor(commonname, unique(commonname)),
         signif=ifelse(p.value<=0.05, "yes","no")) %>% 
  ggplot(aes(x=commonname, y=estimate, ymin=(estimate-std.error), ymax=(estimate+std.error), color=signif, fill=signif)) + 
  geom_pointrange() + 
  scale_colour_manual(values=c("yes" ="#EAAE58","no" = "#37AD97")) + 
  geom_hline(yintercept=0) +
  labs(x=NULL, y="Est. Effect of Year on Edge Position (m)", title="Equatorward Edge Assemblage") +
  coord_flip() +
  NULL
eq.lm.gg

#################
# Make Figure 3 
#################

#################
# Make Figure 4 
#################


pol.edge.tmp <- poldat.lm %>% 
  rename( 
         edge.est = estimate,
         edge.sd = std.error,
         edge.statistic = statistic, 
         edge.pvalue = p.value) 

pol.depth.tmp <- poldat.depth.lm %>% 
  rename(
         depth.est = estimate,
         depth.sd = std.error,
         depth.statistic = statistic,
         depth.pvalue = p.value) %>% 
  left_join(pol.edge.tmp, by=c('commonname','term')) 

pol.ord.tmp <- poldat.abund.lm %>% 
  rename(
    abund.est = estimate,
         abund.sd = std.error,
         abund.statistic = statistic,
         abund.pvalue = p.value) %>% 
  left_join(pol.depth.tmp, by=c('commonname','term')) 

eq.edge.tmp <- eqdat.lm %>% 
  rename(edge.est = estimate,
         edge.sd = std.error,
         edge.statistic = statistic, 
         edge.pvalue = p.value) 

eq.depth.tmp <- eqdat.depth.lm %>% 
  rename(depth.est = estimate,
         depth.sd = std.error,
         depth.statistic = statistic,
         depth.pvalue = p.value) %>% 
  full_join(eq.edge.tmp, by=c('commonname','term'))

eq.ord.tmp <- eqdat.abund.lm %>% 
  rename(abund.est = estimate,
         abund.sd = std.error,
         abund.statistic = statistic,
         abund.pvalue = p.value) %>% 
  left_join(eq.depth.tmp, by=c('commonname','term')) 

# make axes more consistent
# make 4-panel diagram 

pol.depth.shift.gg <- ggplot(data=pol.ord.tmp) + 
  geom_point(aes(x=depth.est, y=edge.est)) +
  geom_errorbar(aes(x=depth.est, ymin = edge.est-edge.sd, ymax = edge.est+edge.sd)) + 
  geom_errorbarh(aes(y=edge.est, xmin = depth.est-depth.sd,xmax = depth.est+depth.sd)) + 
  geom_hline(yintercept=0) + 
  geom_vline(xintercept=0) +
  labs(x="Estimated Effect of Year on Depth (m/yr)", y="Estimated Effect of Year on Edge Position (km/yr)") +
  NULL

eq.depth.shift.gg <- ggplot(data=eq.ord.tmp) + 
  geom_point(aes(x=depth.est, y=edge.est)) +
  geom_errorbar(aes(x=depth.est, ymin = edge.est-edge.sd, ymax = edge.est+edge.sd)) + 
  geom_errorbarh(aes(y=edge.est, xmin = depth.est-depth.sd,xmax = depth.est+depth.sd)) + 
  geom_hline(yintercept=0) + 
  geom_vline(xintercept=0) +
  labs(x="Estimated Effect of Year on Depth (m/yr)", y="Estimated Effect of Year on Edge Position (km/yr)") +
  NULL

pol.depth.shift.gg <- ggplot(data=pol.ord.tmp) + 
  geom_point(aes(x=depth.est, y=edge.est)) +
  geom_errorbar(aes(x=depth.est, ymin = edge.est-edge.sd, ymax = edge.est+edge.sd)) + 
  geom_errorbarh(aes(y=edge.est, xmin = depth.est-depth.sd,xmax = depth.est+depth.sd)) + 
  geom_hline(yintercept=0) + 
  geom_vline(xintercept=0) +
  labs(x="Estimated Effect of Year on Depth (m/yr)", y="Estimated Effect of Year on Edge Position (km/yr)") +
  NULL

pol.abund.shift.gg <- ggplot(data=pol.ord.tmp) + 
  geom_point(aes(x=abund.est, y=edge.est)) +
  geom_errorbar(aes(x=abund.est, ymin = edge.est-edge.sd,ymax = edge.est+edge.sd)) + 
  geom_errorbarh(aes(y=edge.est, xmin = abund.est-abund.sd,xmax = abund.est+abund.sd)) + 
  geom_hline(yintercept=0) + 
  geom_vline(xintercept=0) + 
  labs(x="Estimated Effect of Year on Abundance (kg/yr)", y="Estimated Effect of Year on Edge Position (km/yr)") +
  NULL

eq.abund.shift.gg <- ggplot(data=eq.ord.tmp) + 
  geom_point(aes(x=abund.est, y=edge.est)) +
  geom_errorbar(aes(x=abund.est, ymin = edge.est-edge.sd,ymax = edge.est+edge.sd)) + 
  geom_errorbarh(aes(y=edge.est, xmin = abund.est-abund.sd,xmax = abund.est+abund.sd)) + 
  geom_hline(yintercept=0) + 
  geom_vline(xintercept=0) + 
  labs(x="Estimated Effect of Year on Abundance (kg/yr)", y="Estimated Effect of Year on Edge Position (km/yr)") +
  NULL

#################
# time series 
#################

pol.spp.time <- poldat.stats %>% 
  dplyr::select(commonname, year, spp.dist95) %>% 
  distinct() %>% 
  ggplot(aes(x=year, y=spp.dist95)) +
  geom_line(color="grey39") +
  geom_point(size=0.75) + 
  facet_wrap(~ commonname, ncol=4) +
  theme_linedraw() +
  theme(strip.background =element_rect(fill="grey39"))+
  theme(strip.text = element_text(colour = 'white', face="bold")) +
  scale_x_continuous(limits=c(1968,2017), breaks=seq(1968, 2017, 4)) +
  theme(axis.text.x = element_text(angle=90)) +
  ylab("Poleward Edge Position") +
  xlab("Year") +
  NULL
pol.spp.time

eq.spp.time <- eqdat.stats %>% 
  dplyr::select(commonname, year, spp.dist05) %>% 
  distinct() %>% 
  ggplot(aes(x=year, y=spp.dist05)) +
  geom_line(color="grey39") +
  geom_point(size=0.75) + 
  facet_wrap(~ commonname, ncol=4) +
  theme_linedraw() +
  theme(strip.background =element_rect(fill="grey39"))+
  theme(strip.text = element_text(colour = 'white', face="bold")) +
  scale_x_continuous(limits=c(1968,2017), breaks=seq(1968, 2017, 4)) +
  theme(axis.text.x = element_text(angle=90)) +
  ylab("Equatorward Edge Position") +
  xlab("Year") +
  NULL
eq.spp.time