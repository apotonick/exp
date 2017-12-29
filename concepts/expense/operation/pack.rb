require "zip"

module Claim
  class Pack < Trailblazer::Operation
    step :create_zip

    def create_zip( ctx, claim:, archive_dir:, ** ) #File::Twin
      source_dir   = "."
      source_files = claim.expenses

      zip_file = File.join( archive_dir, "#{claim.identifier}.zip" )

      return false if File.exists?(zip_file)

      Zip::File.open(zip_file, Zip::File::CREATE) do |zip|
        source_files.each do |expense|
           unless expense.file_path # TODO: remove me
            warn "no file_path"
            next
          end

          name_in_zip = "#{expense.index}-#{File.basename(expense.file_path)}"

          zip.add( name_in_zip, File.join(source_dir, expense.file_path) ) # FIXME: this could break
        end
      end



      ctx[:zip] = zip_file
    end
  end
end
