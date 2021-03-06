require "rails_helper"

feature "User sees his vocabulary index page", %(
  As a visitor
  I want to see all the interactions for my bots
  So that I can use them

  Acceptance Criteria
  [X] I must see the list of all the interactions
  [X] I must be able to hide tables depending of the category of the interaction
  [X] I must have a link that it will send the user to new_interaction_path
  [X] I must have a link that it will send the user to edit_interaction_path
  [X] I must be able to delete any interaction
  [X] I must be able to visit other users interactions index page
  [X] I must be able to add any interaction from other users interactions index page

) do
  let!(:user) { FactoryGirl.create(:user) }

  scenario "user sees his sentences in the interaction index page" do
    interaction1 = Interaction.create(
      category: "Sentence",
      sentence: Faker::Lorem.sentence,
      response: Faker::Lorem.sentence,
      user_id: user.id
    )
    login(user)
    visit user_interactions_path(user)

    choose("r1")
    expect(page).to have_content(interaction1.sentence)
    expect(page).to have_content(interaction1.response)
    page.has_css?("sentences row text-center")
    page.has_css?("keywords row text-center hidden")
    page.has_css?("combo row text-center hidden")
  end

  scenario "user sees his keywords in the interaction index page" do
    interaction2 = Interaction.create(
      category: "Keyword",
      sentiment: "Positive",
      keyword1: Faker::Lorem.word,
      response: Faker::Lorem.sentence,
      user_id: user.id
    )
    login(user)

    visit user_interactions_path(user)

    choose("r2")
    expect(page).to have_content(interaction2.keyword1)
    expect(page).to have_content(interaction2.response)
    page.has_css?("sentences row text-center hidden")
    page.has_css?("keywords row text-center")
    page.has_css?("combo row text-center hidden")
  end

  scenario "user sees his combos in the interaction index page" do
    interaction3 = Interaction.create(
      category: "Combo",
      sentiment: "Positive",
      keyword1: Faker::Lorem.word,
      keyword2: Faker::Lorem.word,
      response: Faker::Lorem.sentence,
      user_id: user.id
    )
    login(user)

    visit user_interactions_path(user)

    choose("r3")
    expect(page).to have_content(interaction3.keyword2)
    expect(page).to have_content(interaction3.response)
    page.has_css?("sentences row text-center hidden")
    page.has_css?("keywords row text-center hidden")
    page.has_css?("combo row text-center")
  end
end
