# frozen_string_literal: true

class UpdateEntryVisuals < ApplicationJob
  WAITING_SEC_FOR_VISUAL = 0.5
  queue_as :default

  def perform(max=50)
    Entry.order("published DESC").page(0).per(max)
         .where(visual: nil).find_in_batches(batch_size: 20) do |entries|
      client = Feedlr::Client.new(sandbox: false)
      sleep(WAITING_SEC_FOR_VISUAL)
      feedlr_entries = client.user_entries(entries.pluck(:id))
      hash = entry_and_feedlr_entry_hash(entries, feedlr_entries)
      hash.each do |_id, value|
        entry        = value[:entry]
        feedlr_entry = value[:feedlr_entry]
        visual       = feedlr_entry&.visual
        visual_url   = visual&.url
        if !entry.has_visual? && is_valid_visual_url?(visual_url)
          logger.info("Update the visual of #{entry.url} with #{visual_url}")
          entry.visual = visual.to_json
          entry.save
        end
      end
    end
  end

  def entry_and_feedlr_entry_hash(entries, feedlr_entries)
    hash = entries.each_with_object({}) do |e, h|
      h[e.id] = {} if h[e.id].nil?
      h[e.id][:entry] = e
    end
    feedlr_entries.each_with_object(hash) do |e, h|
      h[e.id][:feedlr_entry] = e
    end
  end

  def is_valid_visual_url?(visual_url)
    visual_url.present? && visual_url != "none"
  end
end
