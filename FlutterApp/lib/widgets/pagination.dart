import 'package:expense_tracker/constants/colors.dart';
import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  final Map<String, dynamic> metadata;
  final Function(int) setPage;
  final int page;

  Pagination(
      {required this.metadata, required this.setPage, required this.page});

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToSelectedPage();
  }

  void _scrollToSelectedPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final selectedButtonContext = context.findRenderObject() as RenderBox;
        final selectedButtonSize = selectedButtonContext.size;
        final selectedButtonOffset =
            selectedButtonContext.localToGlobal(Offset.zero);

        final viewWidth = MediaQuery.of(context).size.width;
        final buttonOffset =
            selectedButtonOffset.dx + (selectedButtonSize.width / 2);
        final scrollPosition = buttonOffset - (viewWidth / 2);

        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed:
              widget.page == 1 ? null : () => widget.setPage(widget.page - 1),
          icon: Icon(Icons.arrow_left),
          disabledColor: tdGrey,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(
                widget.metadata['last_page'],
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => widget.setPage(index + 1),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        widget.page == index + 1 ? tdBlue : Colors.white,
                      ),
                    ),
                    child: Text((index + 1).toString()),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.page == widget.metadata['last_page']
              ? null
              : () => widget.setPage(widget.page + 1),
          icon: Icon(Icons.arrow_right),
          disabledColor: tdGrey,
        ),
      ],
    );
  }
}
