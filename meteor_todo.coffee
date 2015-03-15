Tasks = new (Mongo.Collection)('tasks')


if Meteor.isClient
  Template.body.helpers
    tasks: ->
      Tasks.find {}, { sort: (createdAt: -1) }

  Template.body.events
    'submit .new-task': (event) ->
      console.log(event)
      # This function is called when the new task form is submitted
      text = event.target.text.value
      Tasks.insert
        text: text
        createdAt: new Date # Current time
      event.target.text.value = '' # Clear form
      false # Prevent default form submit actions, as we already handle it
  Template.task.events
    'click .toggle-checked': ->
      # Set the clicked property to the opposite of its current value
      Tasks.update(this._id, $set: checked: !this.checked)
      return
    'click .delete': ->
      Tasks.remove(this._id)
      return


if Meteor.isServer
  Meteor.startup ->
    # code to run on server at startup
