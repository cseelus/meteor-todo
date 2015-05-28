Tasks = new (Mongo.Collection)('tasks')


if Meteor.isClient
  Meteor.subscribe "tasks"
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
      Meteor.call("addTask", text)
      event.target.text.value = '' # Clear form
      false # Prevent default form submit actions, as we already handle it
    'change .hide-completed input': (event) ->
      Session.set("hideCompleted", event.target.checked)

  Template.task.helpers
    isOwner: ->
      this.owner is Meteor.userId()

  Template.task.events
    'click .toggle-checked': ->
      # Set the clicked property to the opposite of its current value
      Meteor.call("setChecked", this._id, !this.checked)
      return
    'click .delete': ->
      Meteor.call("deleteTask", this._id)
      return
    'click .toggle-private': ->
      Meteor.call("setPrivate", this._id, !this.private)

  Accounts.ui.config
    passwordSignupFields: "USERNAME_ONLY"


if Meteor.isServer
  # Only publish tasks that are public or belong to the current user
  Meteor.publish 'tasks', ->
    Tasks.find $or: [
      { private: $ne: true }
      { owner: this.userId }
    ]


Meteor.methods
  addTask: (text) ->
    # Make sure the user is logged in before inserting a task
    throw new Meteor.Error("not-authorized")  unless Meteor.userId()
    Tasks.insert
      text: text
      createdAt: new Date()
      owner: Meteor.userId()
      username: Meteor.user().username
  deleteTask: (taskId) ->
    task = Tasks.findOne(taskId)
    if task.private and task.owner != Meteor.userId()
      # If the task is private, make sure only the owner can delete it
      throw new (Meteor.Error)('not-authorized')
    Tasks.remove taskId
  setChecked: (taskId, setChecked) ->
    task = Tasks.findOne(taskId)
    if task.private and task.owner != Meteor.userId()
      # If the task is private, make sure only the owner can check it off
      throw new (Meteor.Error)('not-authorized')
    Tasks.update taskId,
      $set:
        checked: setChecked
  setPrivate: (taskId, setToPrivate) ->
    task = Tasks.findOne(taskId)
    # Make sure only the task owner can make a task private
    throw new Meteor.Error("not-authorized")  if task.owner isnt Meteor.userId()
    Tasks.update taskId,
      $set:
        private: setToPrivate
