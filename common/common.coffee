# LifeChart -- data model
# Loaded on both the client and the server

#/////////////////////////////////////////////////////////////////////////////
# Transactions

#
# Each transaction is represented by a document in the Transactions collection:
#   owner: user id
#   date: date of transaction
#   transaction_type: sale type of transaction e.g POS, Direct Debit
#   description: description of transaction, which is later parsed for tagging
#   tags: type of transaction, e.g food, electricity - is an array of tags
#   value: amount of transaction
#   balance: current balance of account
#   account_name: name of account
#   account_number: account number
#
Transactions = new Meteor.Collection("transactions")
Transactions.allow
  insert: (userId, transaction) ->
    false # no inserts -- use addTransaction method

  update: (userId, transaction, fields, modifier) ->
    return false if userId isnt transaction.owner # not the owner
    allowed = ["description", "tags"]
    return false if _.difference(fields, allowed).length # tried to write to forbidden field
    
    # A good improvement would be to validate the type of the new
    # value of the field (and if a string, the length.) In the
    # future Meteor will have a schema system to makes that easier.
    true

  remove: (userId, transaction) ->
    transaction.owner is userId

Meteor.methods
  addTransaction: (options) ->
    options = options or {}
    throw new Meteor.Error(403, "You must be logged in") unless @userId
    throw new Meteor.Error(400, "Required parameter missing") unless (
      typeof options.date is "Date" and options.date.length and 
      typeof options.transaction_type is "string" and options.transaction_type.length and 
      typeof options.description is "string" and options.description.length and
      typeof options.value is "number" and options.value.length and 
      typeof options.balance is "number" and options.balance.length and 
      typeof options.account_name is "string" and options.account_name.length and 
      typeof options.account_number is "number" and options.account_number.length 
    )
    throw new Meteor.Error(413, "Description too long") if options.description.length > 1000

    Transactions.insert
      owner: @userId
      date: options.date
      transaction_type: options.transaction_type
      description: options.description
      tags: options.tags
      value: options.value
      balance: options.balance
      account_name: options.account_name
      account_number: options.account_number

#/////////////////////////////////////////////////////////////////////////////
# Users
displayName = (user) ->
  return user.profile.name if user.profile and user.profile.name
  user.emails[0].address

contactEmail = (user) ->
  return user.emails[0].address if user.emails and user.emails.length
  return user.services.facebook.email if user.services and user.services.facebook and user.services.facebook.email
  null