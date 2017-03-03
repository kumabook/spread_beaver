desc "Clear latest likes"
task :clear_latest_likes => :environment do
  from = V3::Streams::TracksController::DURATION.ago
  to   = from + V3::Streams::TracksController::DURATION
  puts "Deleting latest #{EnclosureLike.period(from, to).count} likes..."
  EnclosureLike.period(from, to).destroy_all
  puts "Complete deleting. Current likes count is #{EnclosureLike.period(from, to).count}"
end
