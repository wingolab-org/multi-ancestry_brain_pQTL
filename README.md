# Multi-ancestry Brain pQTL Code Sharing

**Publication**: Wingo et al., _Multi-ancestry brain pQTL fine-mapping and
integration with genome-wide association studies of 21 neurologic and
psychiatric conditions_

This repository provides transparency for critical analysis details of the
manuscript.

For MESuSiE analysis notes were collated with minimal editing and shared as:
[`MESuSiE_notes.txt`](multi-MESuSiE_notes.txt) with scripts shared in
`./MESuSiE`.

For converting genomic mapping to a jointly VCF dataset, we followed the
approach in [pecaller](https://github.com/wingolab-org/pecaller) using
[samstools](https://www.htslib.org/) to generate mpileup files used as input for
`mpileup_to_pileup2`. Variant calling, Quality Control & Site Selection,
Cross-Batch Merging, and Final Integration steps were followed using default
values with final quality control parameters given in the manuscript.

Code was tidied for readability using
[perltidy](https://metacpan.org/pod/Code::TidyAll::Plugin::PerlTidy),
[prettier](https://prettier.io/), [shfmt](https://github.com/mvdan/sh), and
[styler](https://styler.r-lib.org/).
