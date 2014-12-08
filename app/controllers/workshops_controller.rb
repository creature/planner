class WorkshopsController < ApplicationController
  def show
    @workshop = WorkshopPresenter.new(Sessions.find(params[:id]))
  end


  # Add a user to this workshop, either to the attendees or the waiting list.
  def add
    unless logged_in?
      redirect_to "/auth/github" and return
    end
    @workshop = Sessions.find(params[:id])
    waiting_listed = false
    case params[:role]
      when "student"
        @invitation = SessionInvitation.where(sessions: @workshop, member: current_user, role: "Student").first_or_create
        unless @workshop.student_spaces?
          WaitingList.add(@invitation, true)
          waiting_listed = true
        end
      when "coach"
        @invitation = SessionInvitation.where(sessions: @workshop, member: current_user, role: "Coach").first_or_create
        unless @workshop.coach_spaces?
          WaitingList.add(@invitation, true)
          waiting_listed = true
        end
      else
        redirect_to workshop_path(@workshop) and return
    end

    if waiting_listed
      redirect_to :waitlisted_workshop and return
    else
      redirect_to :added_workshop and return
    end
  end


  # Remove a user from this workshop, either to the attendees or the waiting list.
  def remove
    unless logged_in?
      redirect_to "/auth/github" and return
    end
    @workshop = EventPresenter.new(Sessions.find(params[:id]))
    invitation.update_attribute(:attending, false)
    WaitingList.find_by_invitation_id(invitation.id).delete
    redirect_to @workshop and return
  end


  # Show a "You've been removed from this event" page.
  def removed
  end

  # Show a "You've been added to this event" page.
  def added
  end

  # Show a "You've been waitlisted for this event" page.
  def waitlisted
  end
end