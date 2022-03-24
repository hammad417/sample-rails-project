# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development?
  Admin.create!(email: 'super@example.com', password: 'password',
                password_confirmation: 'password', super_admin: true)

  ['Loan Agreement', 'Salary to Wallet Authorization', 'Statement of Account', 'Loan Repayment Invoice',
   'Stamp duty report', 'VAT report', 'PICO report', 'E-receipt', 'Tax Invoice',
   'Learning Certificates'].each do |d|
    DocumentType.create!(name: d)
  end
end
