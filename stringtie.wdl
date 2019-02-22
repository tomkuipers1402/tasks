version 1.0

import "common.wdl"

task Stringtie {
    input {
        IndexedBamFile bamFile
        File? referenceGtf
        Boolean skipNovelTranscripts = false
        String assembledTranscriptsFile
        Boolean? firstStranded
        Boolean? secondStranded
        String? geneAbundanceFile

        Int threads = 1
        Int memory = 10
        String dockerTag = "1.3.4--py35_0"
    }

    command {
        set -e
        mkdir -p $(dirname ~{assembledTranscriptsFile})
        stringtie \
        ~{"-p " + threads} \
        ~{"-G " + referenceGtf} \
        ~{true="-e" false="" skipNovelTranscripts} \
        ~{true="--rf" false="" firstStranded} \
        ~{true="--fr" false="" secondStranded} \
        -o ~{assembledTranscriptsFile} \
        ~{"-A " + geneAbundanceFile} \
        ~{bamFile.file}
    }

    output {
        File assembledTranscripts = assembledTranscriptsFile
        File? geneAbundance = geneAbundanceFile
    }

    runtime {
        cpu: threads
        memory: memory
        docker: "quay.io/biocontainers/stringtie:" + dockerTag
    }
}

task Merge {
    input {
        Array[File]+ gtfFiles
        String outputGtfPath
        File? guideGtf
        Int? minimumLength
        Float? minimumCoverage
        Float? minimumFPKM
        Float? minimumTPM
        Float? minimumIsoformFraction
        Boolean keepMergedTranscriptsWithRetainedIntrons = false
        String? label

        Int memory = 10
        String dockerTag = "1.3.4--py35_0"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputGtfPath})
        stringtie --merge \
        -o ~{outputGtfPath} \
        ~{"-G " + guideGtf} \
        ~{"-m " + minimumLength } \
        ~{"-c " + minimumCoverage} \
        ~{"-F " + minimumFPKM} \
        ~{"-T " + minimumTPM} \
        ~{"-f " + minimumIsoformFraction} \
        ~{true="-i" false="" keepMergedTranscriptsWithRetainedIntrons} \
        ~{"-l " + label} \
        ~{sep=" " gtfFiles}
    }

    output {
        File mergedGtfFile = outputGtfPath
    }

    runtime {
        memory: memory
        docker: "quay.io/biocontainers/stringtie:" + dockerTag
    }
}
