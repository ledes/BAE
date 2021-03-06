require "rails_helper"
require "pry"

RSpec.describe Bot, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:bots_interactions).dependent(:destroy)  }
  it { should have_many(:interactions).through(:bots_interactions) }

  it { should validate_presence_of :name}
  it { should validate_presence_of :gender}
  it { should validate_presence_of :eye_color}
  it { should validate_presence_of :hair_color}
  it { should validate_presence_of :age}
  it { should validate_numericality_of(:age) }
  it { should validate_numericality_of(:age).is_less_than_or_equal_to(99) }
  it { should validate_numericality_of(:age).is_greater_than_or_equal_to(18) }
  it { should validate_presence_of :user_id }

  it { should have_valid(:age).when("34") }
  it { should_not have_valid(:age).when(nil, "", 12, 204) }

  let!(:user) { FactoryGirl.create(:user) }
  let!(:bot) { FactoryGirl.create(:bot, user_id: user.id) }

  before(:each) do
    ##Sentence
    interaction1 = Interaction.create(
      category: "Sentence",
      sentence: "you are great",
      response: "I have a great teacher",
      user: user
    )

    interaction2 = Interaction.create(
      category: "Sentence",
      sentence: "i want a bike",
      response: "I think you should get one",
      user: user
    )
    ##keyword
    interaction3 = Interaction.create(
      category: "Keyword",
      sentiment: "Positive",
      keyword1: "CARS",
      keyword2: "",
      response: "I like cars too",
      user: user
    )

    interaction4 = Interaction.create(
      category: "Keyword",
      sentiment: "Positive",
      keyword1: "BIkes",
      response: "I love bikes but I prefer cars",
      user: user
    )

    interaction5 = Interaction.create(
      category: "Keyword",
      sentiment: "Positive",
      keyword1: "PORK",
      response: "I like pork a lot!",
      user: user
    )

    interaction6 = Interaction.create(
      category: "Keyword",
      sentiment: "Negative",
      keyword1: "Pork",
      response: "I hate pork!",
      user: user
    )
    ##Combo
    interaction7 = Interaction.create(
      category: "Combo",
      sentiment: "Positive",
      keyword1: "bikes",
      keyword2: "CARS",
      response: "I prefer cars",
      user: user
    )

    interaction8 = Interaction.create(
      category: "Combo",
      sentiment: "Negative",
      keyword1: "BIKES",
      keyword2: "cars",
      response: "I don't like them either",
      user: user
    )

    interaction9 = Interaction.create(
      category: "Combo",
      sentiment: "Positive",
      keyword1: "chicken",
      keyword2: "Pork",
      response: "I love pork but I prefer chicken",
      user: user
    )

    interaction10 = Interaction.create(
      category: "Combo",
      sentiment: "Negative",
      keyword1: "chicken",
      keyword2: "pork",
      response: "Me neither!",
      user: user
    )
    interaction11 = Interaction.create(
      category: "Keyword",
      sentiment: "Positive",
      keyword1: "BACON",
      response: "I love bacon",
      user: user
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction1
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction2
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction3
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction4
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction5
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction6
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction7
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction8
    )

    BotsInteraction.create(
      bot: bot,
      interaction: interaction9
    )
    BotsInteraction.create(
      bot: bot,
      interaction: interaction10
    )
    BotsInteraction.create(
      bot: bot,
      interaction: interaction11
    )
  end

  describe "right_anwer()" do
    scenario "it should return the right answer for a sentence" do
      message = "you are great"
      expect(bot.right_answer(message)).to eq("I have a great teacher")
    end

    scenario "it should return the right answer for a keyword" do
      message = "What do you think about cars?"
      expect(bot.right_answer(message)).to eq("I like cars too")

      message = "great bacon"
      expect(bot.right_answer(message)).to eq("I love bacon")
    end

    scenario "it should return the right answer for a combo" do
      message = "What do you think about cars and bikes?"
      expect(bot.right_answer(message)).to eq("I prefer cars")

       message = "I love pork and chicken"
       expect(bot.right_answer(message)).to eq("I love pork but I prefer chicken")
    end

    scenario "it should return the right answer for a keyword that also exists for a combo" do
      message = "I like cars, What do you think about cars?"
      expect(bot.right_answer(message)).to eq("I like cars too")

      message = "I like pork, What do you think about pork?"
      expect(bot.right_answer(message)).to_not eq("I love pork but I prefer chicken")
    end
  end

  describe "Indico API" do
    scenario "it should return the right answer depending of the sentiment" do
      message = "I don't like pork"
      expect(bot.right_answer(message)).to eq("I hate pork!")

      message = "I love pork"
      expect(bot.right_answer(message)).to eq("I like pork a lot!")

      message = "I don't like pork either chicken"
      expect(bot.right_answer(message)).to eq("Me neither!")

      message = "I like pork either chicken"
      expect(bot.right_answer(message)).to eq("I love pork but I prefer chicken")

      message = "I like cars and bikes"
      expect(bot.right_answer(message)).to eq("I prefer cars")

      message = "I don't like cars neither bikes"
      expect(bot.right_answer(message)).to eq("I don't like them either")

    end
  end

  describe "sentiment?()" do
    scenario "it should return possitive if the indico score is higher than 0.65" do
      message = "I don't like pork"
      expect(bot.sentiment?(message)).to eq("Negative")
    end

    scenario "it should return neutral if the indico score is higher or equal than 0.25" do
      message = "pork is an animal"
      expect(bot.sentiment?(message)).to eq("Neutral")
    end

    scenario "it should should return possitive if the indico score is lower than 0.65" do
      message = "I love pork"
      expect(bot.sentiment?(message)).to eq("Positive")
    end
  end
end
