desc "Clear latest likes"
task :clear_latest_likes => :environment do
  from = V3::Streams::TracksController::DURATION.ago
  to   = from + V3::Streams::TracksController::DURATION
  puts "Deleting latest #{LikedEnclosure.period(from, to).count} likes..."
  LikedEnclosure.period(from, to).destroy_all
  puts "Complete deleting. Current likes count is #{LikedEnclosure.period(from, to).count}"
end
