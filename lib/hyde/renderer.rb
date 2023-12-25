module Jekyll
  class Renderer
    def render_layout(output, layout, info)
      Hyde::Page::Js.new(layout, info).generate

      # TODO Would be nice to call super here instead of cloned logic from Jekyll internals
      payload["content"] = output
      payload["layout"] = Utils.deep_merge_hashes(layout.data, payload["layout"] || {})

      render_liquid(
        layout.content,
        payload,
        info,
        layout.path
      )
    end
  end
end
