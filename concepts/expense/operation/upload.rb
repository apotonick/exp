module Expense
  class Upload < Trailblazer::Operation
    UploadedFile = Struct.new(:path)

    step :upload!

    def upload!(options, params:, **)
      options["files"] = []

      files = params[:files]

      files.each do |cfg|
        file = cfg[:tempfile]

        # FIXME: this is of course absolutely not OK to do in a real app. Use Shrine, S3, Paperdragon, etc.
        # TODO: make this a cool upload.

        path = move_file(file.path)

        options["files"] << UploadedFile.new(path)
      end
    end

    def move_file(path)
      # new_path = File.join("assets", "__uploads", File.basename(path))
      new_path = ::File.join("uploads", ::File.basename(path))
      ::FileUtils.mv(path, new_path)
      new_path
      ::File.basename(new_path)
    end
  end
end
