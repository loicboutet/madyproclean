class PagesController < ApplicationController
  before_action :redirect_if_authenticated, only: [:roles]

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
          
          { path: "/admin/sites", description: "Gestion des sites", clickable: true },
          { path: "/admin/users", description: "Gestion des utilisateurs", clickable: true },
          { path: "/admin/schedules", description: "Gestion des plannings", clickable: true },
         
          { path: "/admin/absences", description: "Consultation des absences", clickable: true },
          { path: "/admin/anomalies", description: "Détection d'anomalies", clickable: true },
          { path: "/admin/reports", description: "Rapports généraux", clickable: true },
          { path: "/admin/reports/monthly", description: "Rapports mensuels", clickable: true },
          { path: "/admin/reports/hr", description: "Indicateurs RH", clickable: true },
          { path: "/dashboard/profile", description: "Profil personnel", clickable: true },
          
        ]
      },
      manager: {
        name: "👔 Superviseur",
        count: "3 utilisateurs",
        access_level: "Accès Blocks 1 & 2 (Limité)",
        description: "Gestion des absences et planning d'équipe",
        routes: [
          { path: "/home", description: "Home", clickable: true },
          { path: "/manager/dashboard", description: "Tableau de bord superviseur", clickable: true },
          { path: "/manager/time_entries", description: "Consultation des pointages", clickable: true },
          { path: "/manager/schedules", description: "Consultation des plannings", clickable: true },
          { path: "/manager/absences", description: "Gestion des absences de l'équipe", clickable: true },
          { path: "/manager/team", description: "Gestion de l'équipe", clickable: true },
          { path: "/manager/replacements", description: "Gestion des remplaçants", clickable: true },

          { path: "/dashboard/profile", description: "Profil personnel", clickable: true },
 
        ]
      }
    }
  end

  private

  def redirect_if_authenticated
    redirect_to_dashboard if current_user
  end
end
