# WGS Pipeline (simplified microbiome analyses)

Custom SLURM scripts built in collaboration with the TGen Microbiome Service Center.

## Project Information
Next-generation sequencing (NGS) has become a powerful tool for human microbiome research. Researchers, now, have the ability to isolate bacterial DNA from clinical microbiome samples while utilizing popular and streamlined approaches for obtaining high-quality sequence reads from high throughput sequencing platforms such as [Illumina](https://www.illumina.com), [Ion torrent](https://www.thermofisher.com/us/en/home/brands/ion-torrent.html), and [PacBio](https://www.pacb.com/smrt-science/smrt-sequencing/). As NGS technology is constantly evolving, translational clinical research is becoming easier to perform [(Beigh, 2016)](https://dx.doi.org/10.3390%2Fmedicines3020014). For example, molecular biologists can focus more on their research, rather than on NGS procedures.

However, there is only one problem. NGS requires molecular biologists and researchers alike to have an understanding of the bioinformatic tools that they are using to perform highly complex analyses. This can become a significant issue when scientific consistency and reproducibility is a major concern [(Sandve et al., 2013)](https://doi.org/10.1371/journal.pcbi.1003285). Because many bioinformatics tool designate their own set of commands, researchers may have a harder time learning bioinformatics and performing back-to-back analyses on sequences obtained from targeted-gene or whole genome sequencing (WGS).

To address this problem, I propose the use of a customizable workflow for reducing the overall time it takes to manually process and analyze sequence reads obtained from WGS, otherwise known as shotgun metagenomics. WGS analyses of clinical human microbiome samples can take hours of tedious commandline entry to produce results, whereas established targeted-gene sequencing workflows seem to be a lot more efficient. For example, the well-known microbiome bioinformatics platform referred to as [QIIME2](https://qiime2.org) can seemlessly perform analyses without error [(Bolyen et al., 2019)](https://doi.org/10.1038/s41587-019-0209-9). There is currently no easy to use WGS microbiome bioinformatics platform, other than [bioBakery](https://github.com/biobakery/biobakery), [Galaxy](https://galaxyproject.org), and or [CyVerse](https://cyverse.org) if seemless results is a wish amongst institutions and their collaborators.

Because WGS provides more insight on bacterial ecology than 16S, an easy to use, customizable WGS workflow can significantly benefit overwhelmed microbiome scientist [(Brumfield et al., 2020)](https://doi.org/10.1371/journal.pone.0228899). This is where the [WGS Pipeline](https://github.com/metro1102/wgs-pipeline) project shines. This project intends to simply the complicated WGS pipeline by automating reduntant tasks such as inputting sequence read names into commands for common applications such as [kneaddata](https://github.com/biobakery/kneaddata), [kraken2](https://github.com/DerrickWood/kraken2) or [metaphlan](https://github.com/biobakery/MetaPhlAn), [bracken](https://github.com/jenniferlu717/Bracken), [krona](https://github.com/marbl/Krona/wiki), and finally [biom](https://github.com/biocore/biom-format).

This project is primarily built using Bash and SLURM scripts for each application mentioned above.

## Project Contributions
Before contributing, please consider reading the below guidelines. These guidelines highlight the importance of git workflow etiquette. For example, commit messages should be consistent with whatever is being added, removed, or changed. Also consider opening a pull request if you would like to suggest a feature or fix for this project. Pull request(s) will be approved in a timely manner. :)

- Make sure to report bugs that may significantly affect research.
- Open a pull request with your changes, following these guidelines.
- Follow these guidelines and your pull request(s) shall be accepted.

## License(s)
GNU General Public License v3.0

## Citations
If you plan on using WGS Pipeline for potential publications, please include the following citation:
> WGS Pipeline (simplified microbiome analyses). (2021). https://github.com/metro1102/wgs-pipeline
