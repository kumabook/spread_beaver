desc "Clear latest likes"
task :clear_latest_likes => :environment do
  from = V3::Streams::TracksController::DURATION.ago
  to   = from + V3::Streams::TracksController::DURATION
  puts "Deleting latest #{Like.period(from, to).count} likes..."
  Like.period(from, to).destroy_all
  puts "Complete deleting. Current likes count is #{Like.period(from, to).count}"
end
