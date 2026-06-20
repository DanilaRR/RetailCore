import { createRouter, createWebHistory, type NavigationGuardNext, type RouteLocationNormalized } from 'vue-router';
import Register from '@/views/Register.vue';
import Login from '@/views/Login.vue';
import Home from '@/views/Home.vue';
import Categories from '@/views/Categories.vue';
import CategoryDetails from '@/views/CategoryDetails.vue';

const routes = [
  { path: '/', redirect: '/login' }, 
  { path: '/register', component: Register },
  { path: '/login', component: Login },
  { path: '/items', redirect: '/categories' },
  { path: '/home', component: Home, meta: { requiresAuth: true } },
  { path: '/categories', component: Categories, meta: { requiresAuth: true } },
  { path: '/category/:categoryId', component: CategoryDetails, meta: { requiresAuth: true } },
  { path: '/:pathMatch(.*)*', redirect: '/login' },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Navigation Guard to check for auth token
router.beforeEach((to: RouteLocationNormalized, _from: RouteLocationNormalized, next: NavigationGuardNext) => {
  const isAuthenticated = !!localStorage.getItem('token');
  
  if (to.matched.some(record => record.meta.requiresAuth) && !isAuthenticated) {
    next('/login');
  } else {
    next();
  }
});

export default router;
