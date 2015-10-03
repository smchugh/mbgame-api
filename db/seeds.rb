# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.create(
    {
        id: Game::AI_PLAYER_ID,
        name: 'MBBot',
        email: 'mbbot@dev.com',
        picture: 'http://www.tvacres.com/images/robots_cartoons_bender_alone.jpg',
        new_password: ENV['AI_PLAYER_PASSWORD'],
        new_password_confirmation: ENV['AI_PLAYER_PASSWORD']
    }
)

