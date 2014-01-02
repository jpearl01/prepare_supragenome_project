#!/usr/bin/env ruby

require 'bio'

=begin
Created this program to make it easy to set up a supragenome project
Just run this in a directory of genbank files to create all the necessary
inputs for an all-against-all fasta alignment

Usage: ruby psp.rb
=end


Dir.mkdir('na_genes') unless File.exists?('na_genes')
Dir.mkdir('aa_genes') unless File.exists?('aa_genes')
Dir.mkdir('contigs')  unless File.exists?('contigs')
Dir.mkdir('fasta_inputs') unless File.exists?('fasta_inputs')
Dir.mkdir('fasta_with_annotations') unless File.exists?('fasta_with_annotations')

def get_file_list
  Dir.glob('*.gbk')
end

def write_na_genes (file_list)
  file_list.each do |f|
    abort("Couldn't open the file #{f}") unless File.exists?(f)
    f_basename = File.basename(f, ".gbk")
    outfile = File.open("na_genes/" + f_basename + ".fna", 'w')
    bio_gbk = Bio::GenBank.open(f)
    count = 0
    puts "#{f_basename} writing NA genes"
    bio_gbk.each do |e|
      e.features.drop(1).each do |gene|
        count += 1
        na_seq = Bio::Sequence::NA.new(e.naseq.splicing(gene.position))
        outfile.write(na_seq.to_fasta(f_basename + "_" + count.to_s))
      end
      
    end
  end
end

def write_aa_genes (file_list)
  file_list.each do |f|
    abort("Couldn't open the file #{f}") unless File.exists?(f)
    f_basename = File.basename(f, ".gbk")
    outfile = File.open("aa_genes/" + f_basename + ".faa", 'w')
    bio_gbk = Bio::GenBank.open(f)
    count = 0
    puts "#{f_basename} writing AA genes"
    bio_gbk.each do |e|
      e.features.drop(1).each do |gene|
        count += 1
        na_seq = Bio::Sequence::NA.new(e.naseq.splicing(gene.position))
        aa_seq = na_seq.translate
        outfile.write(aa_seq.to_fasta(f_basename + "_" + count.to_s))
      end     
    end
  end
end

def write_contigs (file_list)
  file_list.each do |f|
    abort("Couldn't open the file #{f}") unless File.exists?(f)
    f_basename = File.basename(f, ".gbk")
    outfile = File.open("contigs/" + f_basename + "_ctgs.fasta", 'w')
    bio_gbk = Bio::GenBank.open(f)
    count = 0
    puts "#{f_basename} writing contigs"
    bio_gbk.each do |e|
      ctg = e.features.first
      count += 1
      na_seq = Bio::Sequence::NA.new(e.naseq.splicing(ctg.position))
      outfile.write(na_seq.to_fasta(f_basename + "ctg" + count.to_s))
    end
  end
end

#Need a function to write out fasta annotation files for use with my ca.rb program
def write_fasta_annotation (file_list)
  file_list.each do |f|
    abort("Couldn't open the file #{f}") unless File.exists?(f)
    f_basename = File.basename(f, ".gbk")
    outfile = File.open("fasta_with_annotations/" + f_basename + ".fasta", 'w')
    bio_gbk = Bio::GenBank.open(f)
    count = 0
    puts "#{f_basename} writing fasta with annotation"
    bio_gbk.each do |e|
      e.features.drop(1).each do |gene|
        count += 1
        na_seq = Bio::Sequence::NA.new(e.naseq.splicing(gene.position))
        begin
          next if gene.feature == "source"
          outfile.write(na_seq.to_fasta(f_basename + "_" + count.to_s + " product='\"" +gene.assoc['product'] + "'\" " + "loc="+ gene.position))
        rescue
          puts "could not write #{f_basename}"
          puts "gene number " + count.to_s 
          puts gene.assoc['product'] if gene.assoc['product'].exists?
        end
      end     
    end
  end
end

def create_fasta_inputs
  `cat na_genes/* > fasta_inputs/all_na_genes.fasta`
  `cat aa_genes/* > fasta_inputs/all_aa_genes.fasta`
  `cat contigs/* > fasta_inputs/all_contigs.fasta`
end

files = get_file_list
write_na_genes(files)
write_aa_genes(files)
write_contigs(files)
create_fasta_inputs
write_fasta_annotation(files)

puts "Execute these commands on the output to do the all-against-all alignments (with my most recent parameter selection):"
puts "genes against contigs"
puts "/opt/fasta-36.3.5e/bin/fasta36 -E 1 -m 9 -n -Q -d 0 all_na_genes.fasta all_contigs.fasta > na_v_contigs.fasta36"
puts "na genes against aa genes"
puts "/opt/fasta-36.3.5e/bin/tfasty36 -E 1 -m 9 -p -Q -d 0 all_aa_genes.fasta all_na_genes.fasta >aa_vs_na.tfasty36"
