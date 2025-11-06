class PagesController < ApplicationController
  def home
  end

  def roles
    @roles_data = {
      admin: {
        name: "⚙️ Administrateur (Direction)",
        count: "8 utilisateurs",
        access_level: "Accès Complet - Blocks 1 & 2",
        description: "Accès total à toutes les fonctionnalités du système",
        routes: [
          { path: "/admin/dashboard", description: "Tableau de bord administrateur", clickable: true },
          { path: "/admin/time_entries", description: "Gestion des pointages", clickable: true },
          { path: "/admin/time_entries/export", description: "Export des pointages (CSV/Excel)", clickable: true },
          { path: "/admin/sites", description: "Gestion des sites", clickable: true },
          { path: "/admin/sites/:id/qr_code", description: "Génération de QR codes (requiert ID site)", clickable: false },
          { path: "/admin/users", description: "Gestion des utilisateurs", clickable: true },
          { path: "/admin/schedules", description: "Gestion des plannings", clickable: true },
          { path: "/admin/schedules/export", description: "Export des plannings (PDF/Excel)", clickable: true },
          { path: "/admin/absences", description: "Consultation des absences", clickable: true },
          { path: "/admin/anomalies", description: "Détection d'anomalies", clickable: true },
          { path: "/admin/anomalies/:id/resolve", description: "Résolution d'anomalies (requiert ID)", clickable: false },
          { path: "/admin/reports", description: "Rapports généraux", clickable: true },
          { path: "/admin/reports/monthly", description: "Rapports mensuels", clickable: true },
          { path: "/admin/reports/hr", description: "Indicateurs RH", clickable: true },
          { path: "/dashboard/profile", description: "Profil personnel", clickable: true },
          { path: "/dashboard/password", description: "Modification du mot de passe", clickable: false }
        ]
      },
      manager: {
        name: "👔 Superviseur",
        count: "3 utilisateurs",
        access_level: "Accès Blocks 1 & 2 (Limité)",
        description: "Gestion des absences et planning d'équipe",
        routes: [
          { path: "/manager/dashboard", description: "Tableau de bord superviseur", clickable: true },
          { path: "/manager/time_entries", description: "Consultation des pointages", clickable: true },
          { path: "/manager/schedules", description: "Consultation des plannings", clickable: true },
          { path: "/manager/absences", description: "Gestion des absences de l'équipe", clickable: true },
          { path: "/manager/team", description: "Gestion de l'équipe", clickable: true },
          { path: "/manager/replacements", description: "Gestion des remplaçants", clickable: true },
          { path: "/manager/replacements/assign", description: "Assignation de remplaçants (POST)", clickable: false },
          { path: "/dashboard/profile", description: "Profil personnel", clickable: true },
          { path: "/dashboard/password", description: "Modification du mot de passe", clickable: false }
        ]
      },
      agent: {
        name: "👤 Agent de Terrain",
        count: "100-140 utilisateurs",
        access_level: "Block 1 Uniquement (Interface Minimale)",
        description: "Interface minimaliste de pointage - aucune information visible",
        routes: [
          { path: "clock.domain.com/c/:qr_code_token", description: "Interface de pointage QR Code (requiert token)", clickable: false },
          { path: "clock.domain.com/clock/auth", description: "Authentification agent (subdomain)", clickable: false }
        ]
      }
    }
  end
end
