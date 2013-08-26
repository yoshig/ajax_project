# First Ajax Project

**TODO**: use data-id to avoid many callbacks.

This project is a simple secret sharing project. I've written two
models: `User` and `Secret`. I've also built `UsersController` and
`SessionsController` to do login for you.

## Phase I: secrets form

Write a plain-old (non-AJAX) `/users/123/secrets/new` form. You'll
need to create a nested route. Restrict to a `new` action. Make a
top-level `/secrets` resource, too. We'll have our nested `new` form
post to the top-level `/secrets` route (it's preferred to POST to a
top-level route). You can restrict the top-level `secrets` route to
`create`.

Write the form to post a secret. When you post a secret, you are
sharing it to someone's 'wall'. The form at `/users/123/secrets/new`
should post a secret to recipient `123`. Hints:

* You'll need to upload the recipient's `user_id`.
* You should not need to upload the sender's id. Modify the
  `SecretsController#create` to use the `current_user`'s id.

You can look at a user's page to view the secrets they have been
shared and make sure things are working.

## Phase II: Add friendships

Write a `Friendship` model to join `User` to `User`. Friendship is
one-way in this application; I used `out_friend` and `in_friend` as
associations.

Write a simple `Friendships` controller (the only action needed is
`create`, I think). Setup a top-level `friendships` resource. Again,
you'll want to post `in_friend_id`, but `out_friend_id` can be
calculated from the current user.

Add a `/users` index page, list all users, and add a "Friend" button
for each.

Make the form a "remote" form: submit it via AJAX.

When clicked, change the button text to "Friending..." and disable the
submit button. When the request succeeds, change the text to
"Friended". Test this out by adding a `sleep(2)` to your
`FriendshipsController#create` action. For two seconds, you should
show "Friending...".

When the template is first rendered, appropriately grey-out the button
if a user has already been friended.

## Phase III: Remove friendships

All things must end; you grow apart. You're still proud of your
friend, but you don't stay in touch anymore.

Add a second button, to unfriend a user. You'll need a `destroy`
action on `FriendshipsController`.

You now want the unfriend button to appear when you are friends, and
the friend button to appear when you are not. The cleanest way to do
this is to:

0. Write both buttons (and forms), display them both.
0. Place the two buttons in a div or span, give this a CSS class of
   `friend_buttons`. Likewise, give your buttons classes of `friend`
   and `unfriend`.
0. If we are friends, set a second class on your div:
   `friended`. Otherwise, set `unfriended` as the class.
0. Write a CSS rule so that `.friend_buttons.friended friend` is
   `display: none`. Do likewise for `.friend_buttons.unfriended
   unfriend`.
0. Lastly, when either button is pressed, swap the class of of the div
   (see `$.toggleClass`).

## Interlude: RESTful design and nested resources

Notice how the friend/unfriend action has been written in terms of a
nested `friendship` resource. This is a common pattern: take a verb
action, think of the noun that might be created by that action, and
nest that as a resource. This is one of the secrets to nice, RESTful
designs.

## Phase IV: Remote secrets form

We have a `/users/123/secrets/new` page that displays a form. I'd like
to be able to post a new secret directly from the `/users/123` page.

Move the `new.html.erb` template into a partial (perhaps
`_form.html.erb`). Use AJAX to make the form remote. Render the
partial in `users/show.html.erb` page.

On successful submission, add the new secret to the `ul` listing all
the secrets. Clear the form so the user can submit more secrets! :-)

## Phase V: Simple dynamic form (no nesting)

Let's allow users to tag secrets when they create them. Add `Tag` and
`SecretTagging` models. Set up appropriate associations.

Because `Secret` `has_many :tags, :through => :secret_taggings`, we
can use `Secret#tag_ids=`. We saw how to tag a secret with many tags
through a set of checkboxes. But what if there are lots of tags to
choose from? Do we really want to present 100 checkboxes?

Instead, let's present a single `select` tag. Let's also present a
link "Add another tag". Clicking this link should invoke a JS function
that will add another `select` tag.

### JSON data script trick

Creating new `select` tags means you'll have to create `option` tags:
one for each `Tag`. To give your JavaScript code access to the list of
`Tag`s, I'd store the JSONified `Tag`s in an HTML script tag. Check
out the [bootstrapping data][bootstrapping-data] chapter for hints.

[bootstrapping-data]: https://github.com/appacademy/js-curriculum/blob/master/client-side-js/bootstrapping-data.md

### Underscore template trick

When the user clicks the "Add another tag" link, we need to insert
another select box into the form. Since this involves building HTML to
inject into the form, we can use an underscore template. Recall how to
do this by referring to the
[underscore templates][underscore-templates] reading.

[underscore-templates]: https://github.com/appacademy/js-curriculum/blob/master/client-side-js/underscore-templates.md
