class Game < ActiveRecord::Base
  validates :status, :human_player_id, :piles, presence: true
  serialize :piles, Array

  has_many :turns
  has_and_belongs_to_many :users

  STATUS_ACTIVE = 'active'
  STATUS_COMPLETE = 'complete'

  AI_PLAYER_ID = 1

  before_create do |doc|
    doc.active_player_id = doc.human_player_id
    doc.users.append(User.find(doc.human_player_id))
    doc.users.append(User.find(AI_PLAYER_ID))
  end

  def advance_active_player!
    self.active_player_id = active_player_id == AI_PLAYER_ID ? human_player_id : AI_PLAYER_ID
  end

  def complete_game!
    self.status = STATUS_COMPLETE
    self.winning_player_id = active_player_id
  end

  def is_winner?
    all_empty = true
    piles.each do |num_beans|
      if num_beans > 0
        all_empty = false
        break
      end
    end
    all_empty
  end

  scope :filtered_games, ->(filters) {
    games = []
    self.transaction do
      games = all
      games = games.joins(:games_users).where('games_users.user_id = ?', filters[:user_id]) if filters[:user_id]
      games = games.where(status: filters[:status]) if filters[:status]
      if filters[:user_id]
        if filters[:is_active_player] != nil
          if filters[:is_active_player]
            games = games.where(active_player_id: filters[:user_id])
          else
            games = games.where.not(active_player_id: filters[:user_id])
          end
        end
        if filters[:is_winner] != nil
          if filters[:is_winner]
            games = games.where(winning_player_id: filters[:user_id])
          else
            games = games.where('winning_player_id IS NULL OR winning_player_id != ?', filters[:user_id])
          end
        end
      end
    end

    games
  }
end
