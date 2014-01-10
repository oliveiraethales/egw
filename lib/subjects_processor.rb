require_relative 'egw_subjects_parser'
require_relative 'drive_api'

GoogleDriveAPI.authorize
result = GoogleDriveAPI.get_egw_folder

puts result
# EGWSubjectsParser.process_files
# GoogleDriveAPI.insert_files