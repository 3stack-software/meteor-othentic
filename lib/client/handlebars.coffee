UI.registerHelper 'othentic_status', (providerId) -> Othentic.status(providerId)
UI.registerHelper 'othentic_status_eq', (providerId, status) -> Othentic.isStatus(providerId, status)
UI.registerHelper 'othentic_status_ne', (providerId, status) -> Othentic.notStatus(providerId, status)
UI.registerHelper 'othentic_enabled', (providerId) -> Othentic.isStatus(providerId, Othentic.STATUS_AVAILABLE) or Othentic.isStatus(providerId, Othentic.STATUS_CONNECTED)
