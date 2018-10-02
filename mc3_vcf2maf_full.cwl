cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  tumorID:
    type: string
  normalID:
    type: string
  tumor:
    type: File
  normal:
    type: File
  bed_file:
    type: File?
  centromere:
    type: File
  cosmic:
    type: File
  dbsnp:
    type: File
  refFasta:
    type: File
  vepData:
    type: Directory
  markDir:
    type: Directory
  tumor_analysis_uuid:
    type: string?
  tumor_aliquot_uuid:
    type: string?
  normal_analysis_uuid:
    type: string?
  normal_aliquot_uuid:
    type: string?
  platform:
    type: string?
  center:
    type: string?

steps:
  call_variants:
    run: mc3_variant.cwl
    in:
      tumor: tumor
      normal: normal
      centromere: centromere
      bed_file: bed_file
      cosmic: cosmic
      dbsnp: dbsnp
      reference: refFasta
      tumorID: tumorID
      normalID: normalID
    out:
      - pindelVCF
      - somaticsniperVCF
      - varscansVCF
      - varscaniVCF
      - museVCF
      - mutectVCF
      - radiaVCF
      - indelocatorVCF

  convert:
    run: mc3_vcf2maf.cwl
    in:
      normalID: normalID
      tumorID: tumorID
      museVCF: call_variants/museVCF
      mutectVCF: call_variants/mutectVCF
      somaticsniperVCF: call_variants/somaticsniperVCF
      varscansVCF: call_variants/varscansVCF
      varscaniVCF: call_variants/varscaniVCF
      radiaVCF: call_variants/radiaVCF
      pindelVCF: call_variants/pindelVCF
      indelocatorVCF: call_variants/indelocatorVCF
      refFasta: refFasta
      vepData: vepData
      tumor_bam_name:
        valueFrom: $(inputs.tumor.basename)
      normal_bam_name:
        valueFrom: $(inputs.normal.basename)
      tumor_aliquot_name: tumorID
      normal_aiquot_name: normalID
      tumor_aliquot_uuid: tumor_aliquot_uuid
      normal_aliquot_uuid: normal_aliquot_uuid
      tumor_analysis_uuid: tumor_analysis_uuid
      normal_analysis_uuid: normal_analysis_uuid
      platform: platform
      center: center 

    out:
      - outmaf

  markfiles:
    run: markfiles.cwl
    in:
      sampleID: tumorID
      mergedMAF: convert/outmaf
      mark1dir:
        valueFrom: $(inputs.markDir.path)/mark1
      mark2dir:
        valueFrom: $(inputs.markDir.path)/mark2
    out:
      - markedMAF

outputs:
  outmaf:
    type: File
    outputSource: markfiles/markedMAF    
