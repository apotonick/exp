require "zip"

module Claim
  class Pack < Trailblazer::Operation
    step :create_zip

    # File#records
    #   Record#file_path FIXME: uploaded_file
    # File#identifier
    def create_zip( ctx, file:, upload_dir:, archive_dir:, ** ) #File::Twin
      source_files = file.records

      zip_file = File.join( archive_dir, "#{file.identifier}.zip" )

      return false if File.exists?(zip_file)

      Zip::File.open(zip_file, Zip::File::CREATE) do |zip|
        source_files.each do |record|
          raise "error with #{record.inspect}" unless record.file_path # TODO: remove me

          name_in_zip = "#{record.index}-#{File.basename(record.file_path)}"

          zip.add( name_in_zip, File.join(upload_dir, record.file_path) ) # FIXME: this could break
        end
      end



      ctx[:zip] = zip_file
    end
  end
end
