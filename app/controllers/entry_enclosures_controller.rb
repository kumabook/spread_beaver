class EntryEnclosuresController < ApplicationController
  before_action :set_entry          , only: [:new, :create, :destroy]
  before_action :set_entry_enclosure, only: [:destroy]
  before_action :require_admin

  def new
    @entry_enclosure = EntryEnclosure.new entry_id: @entry.id,
                                          enclosure_type: params[:type]
  end

  def create
    @entry_enclosure = EntryEnclosure.new(entry_enclosure_params)
    begin
      if @entry_enclosure.save
        redirect_to(entry_path(@entry_enclosure.entry))
      else
        redirect_to new_entry_enclosure_path(@entry),
                    notice: @entry_enclosure.errors.full_messages
      end
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to new_entry_enclosure_path(@entry), notice: e.message
    end
  end

  def destroy
    @entry_enclosure.destroy
    redirect_to entry_enclosures_path(@entry)
  end

  private

  def new_entry_enclosure_path(entry)
    type = entry_enclosure_params[:enclosure_type].downcase
    public_send "new_entry_#{type}_path".to_sym, entry
  end

  def entry_enclosures_path(entry)
    type = @entry_enclosure.enclosure_type.downcase.pluralize
    public_send "entry_#{type}_path".to_sym, entry
  end

  def set_entry_enclosure
    @entry_enclosure = EntryEnclosure.find_by(entry_id:     @entry.id,
                                              enclosure_id: params[:id])
  end

  def set_entry
    @entry = Entry.find(params[:entry_id])
  end

  def entry_enclosure_params
    params.require(:entry_enclosure).permit(:entry_id, :enclosure_id, :enclosure_type)
  end
end
