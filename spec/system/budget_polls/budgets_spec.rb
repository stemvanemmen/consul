require "rails_helper"

describe "Admin Budgets" do
  before do
    admin = create(:administrator).user
    login_as(admin)
  end

  context "Index" do
    scenario "Create poll if the budget does not have a poll associated" do
      budget = create(:budget)

      visit admin_budgets_path

      click_link "Admin ballots"

      balloting_phase = budget.phases.find_by(kind: "balloting")

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content(budget.name)
      expect(page).to have_content(balloting_phase.starts_at.to_date)
      expect(page).to have_content(balloting_phase.ends_at.to_date)

      expect(Poll.count).to eq(1)
      expect(Poll.last.budget).to eq(budget)
    end

    scenario "Create poll in current locale if the budget does not have a poll associated", :js do
      budget = create(:budget,
                      name_en: "Budget for climate change",
                      name_fr: "Budget pour le changement climatique")

      visit admin_budgets_path
      select("Français", from: "locale-switcher")

      find(".fas.fa-ellipsis-v").hover
      click_link "Bulletins de l’admin"

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content("Budget pour le changement climatique")

      expect(Poll.count).to eq(1)
      expect(Poll.last.budget).to eq(budget)
    end

    scenario "Display link to poll if the budget has a poll associated" do
      budget = create(:budget)
      poll = create(:poll, budget: budget)

      visit admin_budgets_path

      within "#budget_#{budget.id}" do
        expect(page).to have_link "Admin ballots", href: admin_poll_booth_assignments_path(poll)
      end
    end
  end

  context "Show" do
    scenario "Do not show questions section if the budget have a poll associated" do
      poll = create(:poll, :for_budget)

      visit admin_poll_path(poll)

      within "#poll-resources" do
        expect(page).not_to have_content("Questions")
        expect(page).to have_content("Booths")
        expect(page).to have_content("Officers")
        expect(page).to have_content("Recounting")
        expect(page).to have_content("Results")
      end
    end
  end
end
