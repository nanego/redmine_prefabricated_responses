# Redmine Prefabricated Responses

This plugin allows Redmine users to create and manage prefabricated (pre-written) responses that can be quickly applied to issues.
It streamlines support workflows by enabling teams to reuse common answers, automatically update issue statuses, and optionally reassign issues when applying a response.

## Features

- **Create reusable responses**: Define responses with a name, note text (with wiki formatting support), and optional status change
- **Visibility control**: Responses can be private (personal), public, or restricted to specific roles
- **Project-level or global responses**: Create responses at the project level or as personal responses available across all projects
- **Conditional responses**: Filter responses based on:
  - Initial issue statuses (only show response when issue is in specific statuses)
  - Trackers (only show response for specific issue types)
- **Status automation**: Automatically change issue status when applying a response
- **Assignee automation**: Optionally reassign the issue when applying a response (to a specific user or to the current user)
- **Edit before sending**: Users can modify the response note before applying it to an issue

## Installation

### Dependencies

This plugin requires the following plugin to be installed first:

- **redmine_base_deface**: [https://github.com/nanego/redmine_base_deface](https://github.com/nanego/redmine_base_deface)

For testing (optional):

- **redmine_base_rspec**: [https://github.com/nanego/redmine_base_rspec](https://github.com/nanego/redmine_base_rspec)

### Installation Steps

1. Install the required dependencies (see above)

2. Clone or copy this plugin into your Redmine plugins directory:
   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/nanego/redmine_prefabricated_responses.git
   ```

3. Run the plugin migrations:
   ```bash
   bundle exec rake redmine:plugins:migrate NAME=redmine_prefabricated_responses RAILS_ENV=production
   ```

4. Restart your Redmine application

For more details, see the [official Redmine plugin installation guide](http://www.redmine.org/wiki/redmine/Plugins).

## Configuration

### Permissions

The plugin adds several permissions that can be configured per role in **Administration > Roles and permissions**:

| Permission | Description |
|------------|-------------|
| `manage_public_responses` | Full management of public responses (create, edit, delete) |
| `use_public_responses` | Use public responses on issues |
| `create_prefabricated_responses` | Create new prefabricated responses |
| `edit_public_responses` | Edit existing public responses |
| `delete_public_responses` | Delete public responses |

### Enabling the Module

Enable the "Prefabricated responses" module on your projects:

1. Go to **Project > Settings > Modules**
2. Check "Prefabricated responses"
3. Save

## Usage

### Creating a Response

**Personal responses** (available to any logged-in user):
1. Go to `/responses/new` directly
2. Or for admins: **Administration > Prefabricated responses** then click "Add a prefabricated response"

**Project-level responses** (requires `create_prefabricated_responses` permission):
1. Go to a project's issues list
2. In the sidebar, click "Add a response on this project"

### Applying a Response to an Issue

1. Open an issue and click "Edit"
2. At the top of the edit form, you'll see a dropdown with available responses
3. Select a response from the dropdown
4. Click "Apply to form"
5. The response note will be filled in (you can edit it before saving)
6. If the response has a status change configured, the status field will be updated
7. Click "Submit" to save the changes

### Managing Responses

**Personal responses:**
- Admins: **Administration > Prefabricated responses**
- All users: Access directly via `/responses`

**Project responses:**
- In a project's issues list, use the sidebar link "View all responses on this project"

## Test Status

| Plugin branch | Redmine Version | Test Status       |
|---------------|-----------------|-------------------|
| master        | 6.1.1           | [![6.1.1][1]][5]  |
| master        | 6.0.8           | [![6.0.8][2]][5]  |
| master        | master          | [![master][3]][5] |

[1]: https://github.com/nanego/redmine_prefabricated_responses/actions/workflows/6_1_1.yml/badge.svg
[2]: https://github.com/nanego/redmine_prefabricated_responses/actions/workflows/6_0_8.yml/badge.svg
[3]: https://github.com/nanego/redmine_prefabricated_responses/actions/workflows/master.yml/badge.svg
[5]: https://github.com/nanego/redmine_prefabricated_responses/actions

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License.
