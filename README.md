# First Ajax Project

This project is a simple secret sharing project. I've written two
models: `User` and `Secret`. I've also built `UsersController` and
`SessionsController` to do login for you (I just stole them from
the NewAuthDemo you've read before).

## Phase I: secrets form

Write a plain-old (non-AJAX) `/users/123/secrets/new` form. You'll
need to create a nested route and controller. Restrict to a `new`
action.

Make a top-level `/secrets` resource, too. We'll have our nested `new`
form post to the top-level `/secrets` route (it's preferred to POST to
a top-level route). You can restrict the top-level `secrets` route to
`create`.

Write the form to post a secret. When you post a secret, you are
sharing it to someone's 'wall'. The form at `/users/123/secrets/new`
should post a secret to recipient `123`. Hints:

* You'll need to upload the recipient's `user_id`.
* You should not need to upload the sender's id. In
  `SecretsController#create` use the `current_user`'s id.

You can look at a user's page to view the secrets they have been
shared and make sure things are working. Redirect to the recipient's
user page on successful secret completion.

## Phase II: Add friendships

Write a `Friendship` model to join `User` to `User`. For simplicity,
let's make friendship one-way. I used `out_friend_id`/`in_friend_id`
columns and `out_friend`/`in_friend` associations. Add appropriate
indices, as ever. What presence/uniqueness validation should you add?
Add DB constraints.

We want to write a `/users` index page, listing all the users, and
showing buttons to allow us to friend people.

Write a simple `Friendships` controller (the only action needed is
`create`, I think). Nest a `friendships` resource:
`/users/:user_id/friendship`. Your form should need neither
`in_friend_id` nor `out_friend_id`. You can just `save!` here; assume
there are no validation errors.

Begin writing the users index. Add a button next to each user to allow
us to friend a user. To do this, write a brief form posting to
`/users/:user_id/friendship`. You should not need to post either
`in_friend_id` nor `out_friend_id`. Put this in a partial
`friendships/_form.html.erb`. Pass in the appropriate `user` local
variable.

Okay. Not everyone should get a friend button. Here's people we can't
friend:

* Anyone we have friended in the past.
* Ourself.

Write a `Friendship::can_friend?(out_friend_id, in_friend_id)`
helper. Use ActiveRecord's `exists?` method.

Make sure things are working. You should be able to click to friend
"Gizmo" and after the page refresh, the button should disappear.

## Phase III: Remote friendships

Okay, you've got it working nice. Now, let's toss away your form (oh
no!). We're going to make this a remote form using AJAX.

Instead of rendering the form partial, just add lone `button`
element. The button doesn't need to live within a form. Give the
button a class like `friend`.

Okay, let's write some JavaScript! Let's be bad and put it in an
inline script tag in our `users/index.html.erb` view.

Attach a click handler to the buttons within the list of users. No
matter how many users you have, you should only need to define one
handler and install it once. Use jQuery's event delegation to do
this. In particular, you'll need to use a `data-*` attribute on the
button: what data will you need? How will you gain access to the data
attribute in the event handler?

For now, just pop-up an alert when the button is clicked. Check that
this is working.

Okay! Last step! Instead of just popping up an alert, use `$.ajax` to
make a POST request and construct a `Friendship`. You'll be glad to
have that `id` now, won't you? :-)

You'll want a success callback; go ahead and `remove` the button when
done.

One last thing before you move on. Please disable the button (lookup
on MDN/jQuery how to do this), changing the text to "Friending...",
while in the midst of of friending. You can test this out by adding a
`sleep(2)` to your `FriendshipsController#create` action.

## Phase IV: Remove friendships

Oh no. Your social ineptitude has destroyed another friendship. There
is nothing left to do but ignominiously de-friend them.

Add a second button, to unfriend a user. You'll need a `destroy`
action on `FriendshipsController`. Write a `Friendship::can_unfriend`
method. Show the button if this is true. Again, attach a click handler
that will remove the friendship.

We'll worry about toggling the friend/unfriend buttons in a
second. For now just remove the unfriend button on success; there
should be no buttons left.

If you try to issue a `redirect_to` in response to an AJAX request,
the request will probably fail. Since all our requests to
`FriendshipsController` are through AJAX now, you can more easily
indicate success without returning any data with `head :ok`
(alternatively you could give the status code number: `head
200`). This issues just a blank response.

### Toggling

You now want the unfriend button to appear when you are friends, and
the friend button to appear when you are not. The cleanest way to do
this is to:

0. Write both buttons, display them both.
0. Place the two buttons in a div or span, give this a CSS class of
   `friend-buttons`. Likewise, give your buttons classes of `friend`
   and `unfriend` (they already have these, I should hope!).
0. If we are friends, set a second class on your div:
   `can-unfriend`. Otherwise, set `can-friend` as the class.
0. Write a CSS rule so that `span.friend-buttons.can-unfriend button.friend`
   is `display: none`. Do likewise for `span.friend-buttons.can-friend
   button.unfriend`.
0. Lastly, when either button is pressed, in the success callback swap
   the class of of the `friend-buttons`'s div/span (see
   `$.toggleClass`).
     * I wrote this in a JS helper function, `toggleFriendButtons`. I
       used this for both callbacks.

To keep things easy, you can remove the logic that greys out and
disables buttons.

## Interlude: RESTful design and nested resources

Notice how the friend/unfriend action has been written in terms of a
nested `friendship` resource. This is a common pattern: take a verb
action, think of the noun that might be created by that action, and
nest that as a resource. This is one of the secrets to nice, RESTful
designs.

## Phase V: Remote secrets form

We have a `/users/123/secrets/new` page that displays a form. I'd like
to be able to post a new secret directly from the `/users/123` page.

Move the `new.html.erb` template into a partial (perhaps
`_form.html.erb`). Use AJAX to make the form remote. Render the
partial in `users/show.html.erb` page.

On successful submission, add the new secret to the `ul` listing all
the secrets. Clear the form so the user can submit more secrets! :-)

## Phase VI: Simple dynamic form (no nesting)

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
