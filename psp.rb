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

def get_file_list
  Dir.glob('*.gbk')
end

def change_gene_names (bio_gbk, filename)

end

def change_contig_names (bio_gbk, filename)

end

def write_na_genes (file_list)
  file_list.each do |f|
    abort("Couldn't open the file #{f}") unless File.exists?(f)
    f_basename = File.basename(f, ".gbk")
    outfile = File.open("na_genes/" + f_basename + ".fasta", 'w')
    bio_gbk = Bio::GenBank.open(f)
    count = 0
    bio_gbk.each do |e|
      e.features.drop(1).each do |gene|
        count += 1
        na_seq = Bio::Sequence::NA.new(e.naseq.splicing(gene.position))
        outfile.write(na_seq.to_fasta(f_basename + "_" + count.to_s))
      end
      
    end
  end
end

files = get_file_list

write_na_genes(files)

def write_aa_genes (file_list)

end

def write_contigs (file_list)

end

def create_fasta_inputs

end

get_file_list.each do |f|
  puts f
end
