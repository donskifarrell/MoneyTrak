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
@Transactions = new Meteor.Collection("transactions")
Transactions.allow
  insert: (userId, transaction) ->
    true # no inserts -- use addTransaction method

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
  addTransactions: (options) ->
    options = options or {}
    throw new Meteor.Error(403, "You must be logged in") unless @userId
    throw new Meteor.Error(400, "Required array parameter missing") unless (
      Object.prototype.toString.call( options.transactions ) == '[object Array]' and 
      options.transactions.length
    )
    Meteor.call('addTransaction', transaction) for transaction in options.transactions 

  addTransaction: (transaction) ->
    transaction = transaction or {}
    throw new Meteor.Error(403, "You must be logged in") unless @userId
    throw new Meteor.Error(400, "Required parameter missing") unless (
      typeof transaction.Date is "string" and transaction.Date.length > 0 and
      typeof transaction.Description is "string" and transaction.Description.length > 0 and
      typeof transaction.Value is "number" and 
      typeof transaction.Balance is "number" and 
      typeof transaction["Account Name"] is "string" and transaction["Account Name"].length > 0 and 
      typeof transaction["Account Number"] is "string" and transaction["Account Number"].length > 0 
    )
    throw new Meteor.Error(413, "Transaction description is too long") if transaction.Description.length > 1000

    Transactions.insert
      owner: @userId
      date: new Date(transaction.Date.split('/')[2], 
                    transaction.Date.split('/')[1] - 1, 
                    transaction.Date.split('/')[0])
      transaction_type: transaction.Type
      description: transaction.Description
      tags: transaction.Tags
      value: transaction.Value
      balance: transaction.Balance
      account_name: transaction["Account Name"]
      account_number: transaction["Account Number"]

#/////////////////////////////////////////////////////////////////////////////
# Users
displayName = (user) ->
  return user.profile.name if user.profile and user.profile.name
  user.emails[0].address

contactEmail = (user) ->
  return user.emails[0].address if user.emails and user.emails.length
  return user.services.facebook.email if user.services and user.services.facebook and user.services.facebook.email
  null