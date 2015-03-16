Tasks = new (Mongo.Collection)('tasks')


if Meteor.isClient
  Template.body.helpers
    tasks: ->
      if Session.get("hideCompleted")
        # If hide completed is checked, filter tasks
        Tasks.find { checked: $ne: true }, sort: createdAt: -1
      else
        # Otherwise, return all of the tasks
        Tasks.find {}, sort: createdAt: -1
    hideCompleted: ->
      Session.get 'hideCompleted'
    incompleteCount: ->
      Tasks.find(checked: $ne: true).count()

  Template.body.events
    'submit .new-task': (event) ->
      console.log(event)
      # This function is called when the new task form is submitted
      text = event.target.text.value
      Tasks.insert
        text: text
        createdAt: new Date() # current time
        owner: Meteor.userId() # _id of logged in user
        username: Meteor.user().username # username of logged in user
      event.target.text.value = '' # Clear form
      false # Prevent default form submit actions, as we already handle it
    'change .hide-completed input': (event) ->
      Session.set("hideCompleted", event.target.checked)
  Template.task.events
    'click .toggle-checked': ->
      # Set the clicked property to the opposite of its current value
      Tasks.update(this._id, $set: checked: !this.checked)
      return
    'click .delete': ->
      Tasks.remove(this._id)
      return
  Accounts.ui.config
    passwordSignupFields: "USERNAME_ONLY"


if Meteor.isServer
  Meteor.startup ->
    # code to run on server at startup
