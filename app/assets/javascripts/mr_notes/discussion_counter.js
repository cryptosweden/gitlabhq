import Vue from 'vue';
import DiscussionCounter from '~/notes/components/discussion_counter.vue';
import store from '~/mr_notes/stores';

export function initDiscussionCounter() {
  const el = document.getElementById('js-vue-discussion-counter');

  if (el) {
    const { blocksMerge } = el.dataset;

    // eslint-disable-next-line no-new
    new Vue({
      el,
      name: 'DiscussionCounter',
      components: {
        DiscussionCounter,
      },
      store,
      render(createElement) {
        return createElement('discussion-counter', {
          props: {
            blocksMerge: blocksMerge === 'true',
          },
        });
      },
    });
  }
}
